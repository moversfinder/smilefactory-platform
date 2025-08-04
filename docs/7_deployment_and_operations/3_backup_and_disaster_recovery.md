# 3. Backup and Disaster Recovery

## 🛡️ **Backup and Disaster Recovery Overview**

This document outlines the comprehensive backup and disaster recovery strategy for the ZbInnovation platform, including data backup procedures, system recovery plans, business continuity measures, and disaster recovery testing protocols.

## 🏗️ **Backup Strategy Architecture**

### **Backup Tiers and Retention**
```
┌─────────────────────────────────────────────────────────────┐
│                    Backup Strategy                         │
├─────────────────────────────────────────────────────────────┤
│ Tier 1: Real-time Replication                             │
│ - Database: Synchronous replication to standby             │
│ - Files: Real-time sync to secondary storage               │
│ - RPO: 0 seconds | RTO: 5 minutes                         │
├─────────────────────────────────────────────────────────────┤
│ Tier 2: Frequent Backups                                  │
│ - Database: Every 15 minutes                               │
│ - Application: Every hour                                   │
│ - RPO: 15 minutes | RTO: 30 minutes                       │
├─────────────────────────────────────────────────────────────┤
│ Tier 3: Daily Backups                                     │
│ - Full system backup: Daily at 2 AM UTC                   │
│ - Cross-region replication                                 │
│ - RPO: 24 hours | RTO: 4 hours                           │
├─────────────────────────────────────────────────────────────┤
│ Tier 4: Long-term Archive                                 │
│ - Monthly snapshots: 12 months retention                   │
│ - Yearly archives: 7 years retention                       │
│ - RPO: 1 month | RTO: 24 hours                           │
└─────────────────────────────────────────────────────────────┘
```

### **Backup Components**
```yaml
backup_components:
  database:
    primary: "PostgreSQL RDS with Multi-AZ"
    backup_frequency: "15 minutes"
    retention: "35 days"
    cross_region: true
    encryption: "AES-256"
  
  application_data:
    user_uploads: "S3 with versioning"
    configuration: "Git repository"
    secrets: "AWS Secrets Manager"
    backup_frequency: "1 hour"
    retention: "90 days"
  
  infrastructure:
    kubernetes_configs: "Git repository"
    terraform_state: "S3 with versioning"
    docker_images: "ECR with lifecycle policies"
    backup_frequency: "On change"
    retention: "Indefinite"
  
  monitoring_data:
    metrics: "Prometheus with remote storage"
    logs: "Elasticsearch with snapshots"
    traces: "Jaeger with archival"
    retention: "30 days active, 1 year archive"
```

## 💾 **Database Backup Implementation**

### **PostgreSQL Backup Strategy**
```bash
#!/bin/bash
# scripts/backup-database.sh

set -euo pipefail

# Configuration
DB_HOST="${DB_HOST:-zbinnovation-db.cluster-xyz.us-east-1.rds.amazonaws.com}"
DB_NAME="${DB_NAME:-zbinnovation}"
DB_USER="${DB_USER:-backup_user}"
BACKUP_BUCKET="${BACKUP_BUCKET:-zbinnovation-backups}"
RETENTION_DAYS="${RETENTION_DAYS:-35}"

# Timestamp for backup file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="zbinnovation_backup_${TIMESTAMP}.sql.gz"

# Create backup directory
BACKUP_DIR="/tmp/backups"
mkdir -p "${BACKUP_DIR}"

echo "Starting database backup at $(date)"

# Create database dump with compression
pg_dump \
  --host="${DB_HOST}" \
  --username="${DB_USER}" \
  --dbname="${DB_NAME}" \
  --no-password \
  --verbose \
  --format=custom \
  --compress=9 \
  --file="${BACKUP_DIR}/${BACKUP_FILE}"

# Verify backup integrity
if pg_restore --list "${BACKUP_DIR}/${BACKUP_FILE}" > /dev/null 2>&1; then
  echo "Backup integrity verified"
else
  echo "Backup integrity check failed"
  exit 1
fi

# Upload to S3
aws s3 cp "${BACKUP_DIR}/${BACKUP_FILE}" "s3://${BACKUP_BUCKET}/database/" \
  --storage-class STANDARD_IA \
  --server-side-encryption AES256

# Verify upload
if aws s3 ls "s3://${BACKUP_BUCKET}/database/${BACKUP_FILE}" > /dev/null; then
  echo "Backup uploaded successfully to S3"
  rm -f "${BACKUP_DIR}/${BACKUP_FILE}"
else
  echo "Failed to upload backup to S3"
  exit 1
fi

# Clean up old backups
echo "Cleaning up backups older than ${RETENTION_DAYS} days"
aws s3 ls "s3://${BACKUP_BUCKET}/database/" | \
  awk '{print $4}' | \
  while read -r file; do
    if [[ -n "$file" ]]; then
      file_date=$(echo "$file" | grep -oE '[0-9]{8}' | head -1)
      if [[ -n "$file_date" ]]; then
        file_timestamp=$(date -d "$file_date" +%s)
        cutoff_timestamp=$(date -d "${RETENTION_DAYS} days ago" +%s)
        
        if [[ $file_timestamp -lt $cutoff_timestamp ]]; then
          echo "Deleting old backup: $file"
          aws s3 rm "s3://${BACKUP_BUCKET}/database/$file"
        fi
      fi
    fi
  done

echo "Database backup completed at $(date)"

# Send notification
curl -X POST "${SLACK_WEBHOOK_URL}" \
  -H 'Content-type: application/json' \
  --data "{\"text\":\"✅ Database backup completed successfully: ${BACKUP_FILE}\"}" \
  || echo "Failed to send Slack notification"
```

### **Automated Backup Scheduling**
```yaml
# k8s/backup-cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: database-backup
  namespace: zbinnovation-prod
spec:
  schedule: "*/15 * * * *"  # Every 15 minutes
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: backup
            image: postgres:15-alpine
            command:
            - /bin/bash
            - -c
            - |
              apk add --no-cache aws-cli curl
              /scripts/backup-database.sh
            env:
            - name: PGPASSWORD
              valueFrom:
                secretKeyRef:
                  name: zbinnovation-secrets
                  key: DATABASE_PASSWORD
            envFrom:
            - configMapRef:
                name: backup-config
            volumeMounts:
            - name: backup-scripts
              mountPath: /scripts
          volumes:
          - name: backup-scripts
            configMap:
              name: backup-scripts
              defaultMode: 0755

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: backup-config
  namespace: zbinnovation-prod
data:
  DB_HOST: "zbinnovation-db.cluster-xyz.us-east-1.rds.amazonaws.com"
  DB_NAME: "zbinnovation"
  DB_USER: "backup_user"
  BACKUP_BUCKET: "zbinnovation-backups"
  RETENTION_DAYS: "35"
  SLACK_WEBHOOK_URL: "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
```

## 🔄 **Application Data Backup**

### **File Storage Backup**
```java
// Backend: BackupService.java
@Service
@Slf4j
public class BackupService {
    
    @Autowired
    private AmazonS3 s3Client;
    
    @Value("${aws.s3.backup-bucket}")
    private String backupBucket;
    
    @Value("${aws.s3.source-bucket}")
    private String sourceBucket;
    
    @Scheduled(cron = "0 0 2 * * ?") // Daily at 2 AM
    public void performDailyBackup() {
        log.info("Starting daily backup process");
        
        try {
            // Backup user uploads
            backupUserUploads();
            
            // Backup configuration files
            backupConfigurationFiles();
            
            // Backup application logs
            backupApplicationLogs();
            
            // Clean up old backups
            cleanupOldBackups();
            
            log.info("Daily backup completed successfully");
            
        } catch (Exception e) {
            log.error("Daily backup failed", e);
            notificationService.sendBackupFailureAlert(e);
        }
    }
    
    private void backupUserUploads() {
        String backupPrefix = "user-uploads/" + LocalDate.now().toString() + "/";
        
        ListObjectsV2Request listRequest = new ListObjectsV2Request()
            .withBucketName(sourceBucket)
            .withPrefix("uploads/");
        
        ListObjectsV2Result result;
        do {
            result = s3Client.listObjectsV2(listRequest);
            
            for (S3ObjectSummary object : result.getObjectSummaries()) {
                String sourceKey = object.getKey();
                String backupKey = backupPrefix + sourceKey;
                
                // Copy object to backup bucket
                CopyObjectRequest copyRequest = new CopyObjectRequest(
                    sourceBucket, sourceKey,
                    backupBucket, backupKey
                );
                
                copyRequest.withStorageClass(StorageClass.StandardInfrequentAccess);
                copyRequest.withServerSideEncryptionAwsKmsKeyId("alias/zbinnovation-backup-key");
                
                s3Client.copyObject(copyRequest);
            }
            
            listRequest.setContinuationToken(result.getNextContinuationToken());
        } while (result.isTruncated());
        
        log.info("User uploads backup completed");
    }
    
    private void backupConfigurationFiles() {
        // Backup Kubernetes configurations
        backupKubernetesConfigs();
        
        // Backup application properties
        backupApplicationProperties();
        
        log.info("Configuration files backup completed");
    }
    
    private void backupKubernetesConfigs() {
        try {
            // Execute kubectl to get all configurations
            ProcessBuilder pb = new ProcessBuilder(
                "kubectl", "get", "all,configmaps,secrets", 
                "-n", "zbinnovation-prod", 
                "-o", "yaml"
            );
            
            Process process = pb.start();
            String output = new String(process.getInputStream().readAllBytes());
            
            // Upload to S3
            String key = "k8s-configs/" + LocalDate.now().toString() + "/all-configs.yaml";
            s3Client.putObject(backupBucket, key, output);
            
        } catch (Exception e) {
            log.error("Failed to backup Kubernetes configurations", e);
        }
    }
    
    private void cleanupOldBackups() {
        LocalDate cutoffDate = LocalDate.now().minusDays(90);
        String cutoffPrefix = cutoffDate.toString();
        
        ListObjectsV2Request listRequest = new ListObjectsV2Request()
            .withBucketName(backupBucket);
        
        ListObjectsV2Result result;
        do {
            result = s3Client.listObjectsV2(listRequest);
            
            List<DeleteObjectsRequest.KeyVersion> keysToDelete = result.getObjectSummaries()
                .stream()
                .filter(obj -> obj.getKey().compareTo(cutoffPrefix) < 0)
                .map(obj -> new DeleteObjectsRequest.KeyVersion(obj.getKey()))
                .collect(Collectors.toList());
            
            if (!keysToDelete.isEmpty()) {
                DeleteObjectsRequest deleteRequest = new DeleteObjectsRequest(backupBucket)
                    .withKeys(keysToDelete);
                s3Client.deleteObjects(deleteRequest);
                
                log.info("Deleted {} old backup objects", keysToDelete.size());
            }
            
            listRequest.setContinuationToken(result.getNextContinuationToken());
        } while (result.isTruncated());
    }
}
```

## 🚨 **Disaster Recovery Plan**

### **Recovery Time Objectives (RTO) and Recovery Point Objectives (RPO)**
```yaml
disaster_recovery_objectives:
  critical_systems:
    database:
      rto: "5 minutes"
      rpo: "0 seconds"
      strategy: "Multi-AZ with automatic failover"
    
    api_services:
      rto: "10 minutes"
      rpo: "15 minutes"
      strategy: "Multi-region deployment with load balancer"
    
    frontend:
      rto: "5 minutes"
      rpo: "1 hour"
      strategy: "CDN with multiple origins"
  
  non_critical_systems:
    monitoring:
      rto: "30 minutes"
      rpo: "1 hour"
      strategy: "Backup cluster in secondary region"
    
    analytics:
      rto: "4 hours"
      rpo: "24 hours"
      strategy: "Daily backup restoration"
```

### **Disaster Recovery Procedures**
```bash
#!/bin/bash
# scripts/disaster-recovery.sh

set -euo pipefail

RECOVERY_TYPE="${1:-partial}"  # partial, full, or test
BACKUP_DATE="${2:-latest}"     # specific date or 'latest'

echo "Starting disaster recovery: ${RECOVERY_TYPE} recovery from ${BACKUP_DATE}"

case "${RECOVERY_TYPE}" in
  "partial")
    echo "Performing partial recovery (database only)"
    recover_database "${BACKUP_DATE}"
    ;;
  
  "full")
    echo "Performing full system recovery"
    recover_database "${BACKUP_DATE}"
    recover_application_data "${BACKUP_DATE}"
    recover_infrastructure "${BACKUP_DATE}"
    ;;
  
  "test")
    echo "Performing disaster recovery test"
    test_recovery_procedures
    ;;
  
  *)
    echo "Invalid recovery type: ${RECOVERY_TYPE}"
    echo "Usage: $0 [partial|full|test] [backup_date|latest]"
    exit 1
    ;;
esac

echo "Disaster recovery completed successfully"

function recover_database() {
  local backup_date="$1"
  
  echo "Recovering database from backup: ${backup_date}"
  
  # Find the appropriate backup file
  if [[ "${backup_date}" == "latest" ]]; then
    BACKUP_FILE=$(aws s3 ls "s3://${BACKUP_BUCKET}/database/" | \
      sort | tail -1 | awk '{print $4}')
  else
    BACKUP_FILE=$(aws s3 ls "s3://${BACKUP_BUCKET}/database/" | \
      grep "${backup_date}" | head -1 | awk '{print $4}')
  fi
  
  if [[ -z "${BACKUP_FILE}" ]]; then
    echo "No backup file found for date: ${backup_date}"
    exit 1
  fi
  
  echo "Using backup file: ${BACKUP_FILE}"
  
  # Download backup file
  aws s3 cp "s3://${BACKUP_BUCKET}/database/${BACKUP_FILE}" "/tmp/${BACKUP_FILE}"
  
  # Create new database instance if needed
  if ! aws rds describe-db-instances --db-instance-identifier zbinnovation-recovery > /dev/null 2>&1; then
    echo "Creating recovery database instance"
    aws rds create-db-instance \
      --db-instance-identifier zbinnovation-recovery \
      --db-instance-class db.t3.medium \
      --engine postgres \
      --master-username postgres \
      --master-user-password "${RECOVERY_DB_PASSWORD}" \
      --allocated-storage 100 \
      --vpc-security-group-ids "${SECURITY_GROUP_ID}" \
      --db-subnet-group-name "${DB_SUBNET_GROUP}"
    
    # Wait for instance to be available
    aws rds wait db-instance-available --db-instance-identifier zbinnovation-recovery
  fi
  
  # Restore database
  pg_restore \
    --host="${RECOVERY_DB_HOST}" \
    --username=postgres \
    --dbname=zbinnovation \
    --clean \
    --if-exists \
    --verbose \
    "/tmp/${BACKUP_FILE}"
  
  echo "Database recovery completed"
}

function recover_application_data() {
  local backup_date="$1"
  
  echo "Recovering application data from backup: ${backup_date}"
  
  # Recover user uploads
  aws s3 sync "s3://${BACKUP_BUCKET}/user-uploads/${backup_date}/" \
    "s3://${RECOVERY_BUCKET}/uploads/" \
    --delete
  
  # Recover configuration files
  aws s3 sync "s3://${BACKUP_BUCKET}/k8s-configs/${backup_date}/" \
    "/tmp/recovery-configs/"
  
  echo "Application data recovery completed"
}

function test_recovery_procedures() {
  echo "Testing disaster recovery procedures"
  
  # Test database backup integrity
  test_database_backup_integrity
  
  # Test application startup with recovered data
  test_application_startup
  
  # Test monitoring and alerting
  test_monitoring_systems
  
  echo "Disaster recovery test completed"
}
```

### **Automated Recovery Testing**
```yaml
# k8s/dr-test-cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: disaster-recovery-test
  namespace: zbinnovation-prod
spec:
  schedule: "0 3 * * 0"  # Weekly on Sunday at 3 AM
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: dr-test
            image: zbinnovation/dr-tools:latest
            command:
            - /bin/bash
            - -c
            - |
              echo "Starting automated DR test"
              
              # Test backup integrity
              /scripts/test-backup-integrity.sh
              
              # Test recovery procedures
              /scripts/disaster-recovery.sh test
              
              # Generate DR test report
              /scripts/generate-dr-report.sh
              
              echo "DR test completed"
            envFrom:
            - configMapRef:
                name: dr-config
            - secretRef:
                name: dr-secrets
            volumeMounts:
            - name: dr-scripts
              mountPath: /scripts
          volumes:
          - name: dr-scripts
            configMap:
              name: dr-scripts
              defaultMode: 0755
```

## 📊 **Backup Monitoring and Alerting**

### **Backup Health Monitoring**
```java
// Backend: BackupMonitoringService.java
@Service
@Slf4j
public class BackupMonitoringService {
    
    @Autowired
    private MeterRegistry meterRegistry;
    
    @Autowired
    private NotificationService notificationService;
    
    private final Counter backupSuccessCounter;
    private final Counter backupFailureCounter;
    private final Timer backupDurationTimer;
    
    public BackupMonitoringService(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        
        this.backupSuccessCounter = Counter.builder("backup.success.total")
            .description("Total number of successful backups")
            .register(meterRegistry);
            
        this.backupFailureCounter = Counter.builder("backup.failure.total")
            .description("Total number of failed backups")
            .register(meterRegistry);
            
        this.backupDurationTimer = Timer.builder("backup.duration")
            .description("Backup operation duration")
            .register(meterRegistry);
    }
    
    @EventListener
    public void handleBackupSuccess(BackupSuccessEvent event) {
        backupSuccessCounter.increment(
            Tags.of("type", event.getBackupType(), "component", event.getComponent())
        );
        
        backupDurationTimer.record(
            event.getDuration(), TimeUnit.MILLISECONDS,
            Tags.of("type", event.getBackupType())
        );
        
        log.info("Backup completed successfully: {} for {}", 
            event.getBackupType(), event.getComponent());
    }
    
    @EventListener
    public void handleBackupFailure(BackupFailureEvent event) {
        backupFailureCounter.increment(
            Tags.of("type", event.getBackupType(), "component", event.getComponent())
        );
        
        log.error("Backup failed: {} for {} - {}", 
            event.getBackupType(), event.getComponent(), event.getError());
        
        // Send immediate alert for backup failures
        notificationService.sendBackupFailureAlert(event);
    }
    
    @Scheduled(cron = "0 0 6 * * ?") // Daily at 6 AM
    public void generateBackupReport() {
        BackupReport report = generateDailyBackupReport();
        notificationService.sendBackupReport(report);
    }
    
    private BackupReport generateDailyBackupReport() {
        LocalDateTime yesterday = LocalDateTime.now().minusDays(1);
        
        return BackupReport.builder()
            .reportDate(yesterday.toLocalDate())
            .databaseBackups(getDatabaseBackupStatus(yesterday))
            .fileBackups(getFileBackupStatus(yesterday))
            .configBackups(getConfigBackupStatus(yesterday))
            .overallHealth(calculateOverallHealth())
            .recommendations(generateRecommendations())
            .build();
    }
}
```

---

## 📚 **Reference Documents**

**Production Deployment**: See `/7_deployment_and_operations/1_production_deployment_setup.md`
**Monitoring and Logging**: See `/7_deployment_and_operations/2_monitoring_and_logging.md`
**System Architecture**: See `/2_technical_architecture/1_system_architecture_design.md`
**Security Design**: See `/2_technical_architecture/4_security_and_authentication_design.md`

*This comprehensive backup and disaster recovery strategy ensures business continuity and data protection for the ZbInnovation platform.*
