# 3. Form Handling and Validation

## 📝 **Form Handling and Validation Overview**

This document provides comprehensive guidance for implementing dynamic forms, profile type-specific forms, validation strategies, and form state management in the ZbInnovation platform using React Hook Form and Yup validation.

## 🏗️ **Form Architecture Strategy**

### **Form Library Setup**
```typescript
// src/hooks/useForm.ts
import { useForm as useReactHookForm, UseFormProps } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import * as yup from 'yup';

export interface FormConfig<T> extends UseFormProps<T> {
  schema?: yup.Schema<T>;
  onSubmit: (data: T) => Promise<void> | void;
}

export const useForm = <T extends Record<string, any>>({
  schema,
  onSubmit,
  ...config
}: FormConfig<T>) => {
  const form = useReactHookForm<T>({
    resolver: schema ? yupResolver(schema) : undefined,
    mode: 'onChange',
    ...config,
  });

  const handleSubmit = form.handleSubmit(async (data) => {
    try {
      await onSubmit(data);
    } catch (error) {
      console.error('Form submission error:', error);
    }
  });

  return {
    ...form,
    handleSubmit,
  };
};
```

### **Validation Schema Factory**
```typescript
// src/validation/schemas.ts
import * as yup from 'yup';
import { ProfileType } from '../types/user.types';

export const createProfileSchema = (profileType: ProfileType) => {
  const baseSchema = yup.object({
    firstName: yup
      .string()
      .required('First name is required')
      .min(2, 'First name must be at least 2 characters'),
    lastName: yup
      .string()
      .required('Last name is required')
      .min(2, 'Last name must be at least 2 characters'),
    email: yup
      .string()
      .required('Email is required')
      .email('Please enter a valid email address'),
    bio: yup
      .string()
      .max(500, 'Bio must not exceed 500 characters'),
    phoneNumber: yup
      .string()
      .matches(/^\+?[1-9]\d{1,14}$/, 'Please enter a valid phone number'),
  });

  // Profile type-specific validation
  switch (profileType) {
    case ProfileType.INNOVATOR:
      return baseSchema.shape({
        industryFocus: yup
          .string()
          .required('Industry focus is required'),
        innovationStage: yup
          .string()
          .required('Innovation stage is required'),
        startupName: yup
          .string()
          .min(2, 'Startup name must be at least 2 characters'),
        fundingAmountNeeded: yup
          .number()
          .positive('Funding amount must be positive')
          .max(10000000, 'Funding amount cannot exceed $10M'),
      });

    case ProfileType.BUSINESS_INVESTOR:
      return baseSchema.shape({
        investmentFocus: yup
          .array()
          .of(yup.string())
          .min(1, 'Please select at least one investment focus'),
        ticketSizeMin: yup
          .number()
          .positive('Minimum ticket size must be positive')
          .required('Minimum ticket size is required'),
        ticketSizeMax: yup
          .number()
          .positive('Maximum ticket size must be positive')
          .required('Maximum ticket size is required')
          .test('max-greater-than-min', 'Maximum must be greater than minimum', 
            function(value) {
              return value > this.parent.ticketSizeMin;
            }),
      });

    case ProfileType.MENTOR:
      return baseSchema.shape({
        expertiseAreas: yup
          .array()
          .of(yup.string())
          .min(1, 'Please select at least one expertise area'),
        mentoringExperienceYears: yup
          .number()
          .positive('Experience years must be positive')
          .max(50, 'Experience cannot exceed 50 years'),
        availabilityHoursPerMonth: yup
          .number()
          .positive('Availability hours must be positive')
          .max(160, 'Availability cannot exceed 160 hours per month'),
      });

    default:
      return baseSchema;
  }
};
```

## 📋 **Dynamic Form Components**

### **Dynamic Profile Form**
```typescript
// src/components/forms/ProfileForm/DynamicProfileForm.tsx
import React from 'react';
import { Grid, Typography, Divider } from '@mui/material';
import { useForm } from '../../../hooks/useForm';
import { createProfileSchema } from '../../../validation/schemas';
import { ProfileType } from '../../../types/user.types';

// Form Field Components
import { TextInput } from '../../common/Input/TextInput';
import { SelectInput } from '../../common/Input/SelectInput';
import { MultiSelectInput } from '../../common/Input/MultiSelectInput';
import { NumberInput } from '../../common/Input/NumberInput';
import { TextAreaInput } from '../../common/Input/TextAreaInput';
import { Button } from '../../common/Button/Button';

interface DynamicProfileFormProps {
  profileType: ProfileType;
  initialData?: any;
  onSubmit: (data: any) => Promise<void>;
  loading?: boolean;
}

export const DynamicProfileForm: React.FC<DynamicProfileFormProps> = ({
  profileType,
  initialData,
  onSubmit,
  loading = false,
}) => {
  const schema = createProfileSchema(profileType);
  
  const {
    control,
    handleSubmit,
    formState: { errors, isValid },
  } = useForm({
    schema,
    defaultValues: initialData,
    onSubmit,
  });

  const renderProfileTypeFields = () => {
    switch (profileType) {
      case ProfileType.INNOVATOR:
        return <InnovatorFields control={control} errors={errors} />;
      case ProfileType.BUSINESS_INVESTOR:
        return <InvestorFields control={control} errors={errors} />;
      case ProfileType.MENTOR:
        return <MentorFields control={control} errors={errors} />;
      default:
        return null;
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <Grid container spacing={3}>
        {/* Basic Information */}
        <Grid item xs={12}>
          <Typography variant="h6" gutterBottom>
            Basic Information
          </Typography>
          <Divider sx={{ mb: 2 }} />
        </Grid>

        <Grid item xs={12} sm={6}>
          <TextInput
            name="firstName"
            label="First Name"
            control={control}
            error={errors.firstName?.message}
            required
          />
        </Grid>

        <Grid item xs={12} sm={6}>
          <TextInput
            name="lastName"
            label="Last Name"
            control={control}
            error={errors.lastName?.message}
            required
          />
        </Grid>

        <Grid item xs={12}>
          <TextInput
            name="email"
            label="Email Address"
            type="email"
            control={control}
            error={errors.email?.message}
            required
          />
        </Grid>

        <Grid item xs={12}>
          <TextAreaInput
            name="bio"
            label="Bio"
            control={control}
            error={errors.bio?.message}
            rows={4}
            helperText="Tell us about yourself (max 500 characters)"
          />
        </Grid>

        {/* Profile Type-Specific Fields */}
        <Grid item xs={12}>
          <Typography variant="h6" gutterBottom sx={{ mt: 2 }}>
            {profileType.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase())} Details
          </Typography>
          <Divider sx={{ mb: 2 }} />
        </Grid>

        {renderProfileTypeFields()}

        {/* Submit Button */}
        <Grid item xs={12}>
          <Button
            type="submit"
            variant="primary"
            loading={loading}
            disabled={!isValid}
            fullWidth
            sx={{ mt: 3 }}
          >
            Save Profile
          </Button>
        </Grid>
      </Grid>
    </form>
  );
};
```

### **Profile Type-Specific Field Components**
```typescript
// src/components/forms/ProfileForm/InnovatorFields.tsx
import React from 'react';
import { Grid } from '@mui/material';
import { Control, FieldErrors } from 'react-hook-form';
import { TextInput } from '../../common/Input/TextInput';
import { SelectInput } from '../../common/Input/SelectInput';
import { NumberInput } from '../../common/Input/NumberInput';
import { MultiSelectInput } from '../../common/Input/MultiSelectInput';

interface InnovatorFieldsProps {
  control: Control<any>;
  errors: FieldErrors<any>;
}

export const InnovatorFields: React.FC<InnovatorFieldsProps> = ({
  control,
  errors,
}) => {
  const industryOptions = [
    { value: 'technology', label: 'Technology' },
    { value: 'healthcare', label: 'Healthcare' },
    { value: 'finance', label: 'Finance' },
    { value: 'agriculture', label: 'Agriculture' },
    { value: 'education', label: 'Education' },
    { value: 'energy', label: 'Energy' },
  ];

  const stageOptions = [
    { value: 'idea', label: 'Idea Stage' },
    { value: 'prototype', label: 'Prototype' },
    { value: 'mvp', label: 'MVP' },
    { value: 'beta', label: 'Beta' },
    { value: 'scaling', label: 'Scaling' },
    { value: 'growth', label: 'Growth' },
  ];

  return (
    <>
      <Grid item xs={12} sm={6}>
        <SelectInput
          name="industryFocus"
          label="Industry Focus"
          control={control}
          options={industryOptions}
          error={errors.industryFocus?.message}
          required
        />
      </Grid>

      <Grid item xs={12} sm={6}>
        <SelectInput
          name="innovationStage"
          label="Innovation Stage"
          control={control}
          options={stageOptions}
          error={errors.innovationStage?.message}
          required
        />
      </Grid>

      <Grid item xs={12} sm={6}>
        <TextInput
          name="startupName"
          label="Startup/Project Name"
          control={control}
          error={errors.startupName?.message}
        />
      </Grid>

      <Grid item xs={12} sm={6}>
        <NumberInput
          name="fundingAmountNeeded"
          label="Funding Needed (USD)"
          control={control}
          error={errors.fundingAmountNeeded?.message}
          prefix="$"
        />
      </Grid>

      <Grid item xs={12}>
        <TextInput
          name="startupDescription"
          label="Project Description"
          control={control}
          error={errors.startupDescription?.message}
          multiline
          rows={3}
        />
      </Grid>
    </>
  );
};
```

## 🔄 **Form State Management**

### **Form Context Provider**
```typescript
// src/contexts/FormContext.tsx
import React, { createContext, useContext, useReducer } from 'react';

interface FormState {
  isDirty: boolean;
  isSubmitting: boolean;
  errors: Record<string, string>;
  touchedFields: Set<string>;
}

type FormAction =
  | { type: 'SET_DIRTY'; payload: boolean }
  | { type: 'SET_SUBMITTING'; payload: boolean }
  | { type: 'SET_ERRORS'; payload: Record<string, string> }
  | { type: 'TOUCH_FIELD'; payload: string }
  | { type: 'RESET_FORM' };

const initialState: FormState = {
  isDirty: false,
  isSubmitting: false,
  errors: {},
  touchedFields: new Set(),
};

const formReducer = (state: FormState, action: FormAction): FormState => {
  switch (action.type) {
    case 'SET_DIRTY':
      return { ...state, isDirty: action.payload };
    case 'SET_SUBMITTING':
      return { ...state, isSubmitting: action.payload };
    case 'SET_ERRORS':
      return { ...state, errors: action.payload };
    case 'TOUCH_FIELD':
      return {
        ...state,
        touchedFields: new Set([...state.touchedFields, action.payload]),
      };
    case 'RESET_FORM':
      return initialState;
    default:
      return state;
  }
};

const FormContext = createContext<{
  state: FormState;
  dispatch: React.Dispatch<FormAction>;
} | null>(null);

export const FormProvider: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  const [state, dispatch] = useReducer(formReducer, initialState);

  return (
    <FormContext.Provider value={{ state, dispatch }}>
      {children}
    </FormContext.Provider>
  );
};

export const useFormContext = () => {
  const context = useContext(FormContext);
  if (!context) {
    throw new Error('useFormContext must be used within a FormProvider');
  }
  return context;
};
```

### **Auto-Save Hook**
```typescript
// src/hooks/useAutoSave.ts
import { useEffect, useRef } from 'react';
import { useWatch } from 'react-hook-form';
import { debounce } from 'lodash';

interface UseAutoSaveProps {
  control: any;
  onSave: (data: any) => Promise<void>;
  delay?: number;
  enabled?: boolean;
}

export const useAutoSave = ({
  control,
  onSave,
  delay = 2000,
  enabled = true,
}: UseAutoSaveProps) => {
  const watchedData = useWatch({ control });
  const debouncedSave = useRef(
    debounce(async (data: any) => {
      try {
        await onSave(data);
      } catch (error) {
        console.error('Auto-save failed:', error);
      }
    }, delay)
  ).current;

  useEffect(() => {
    if (enabled && watchedData) {
      debouncedSave(watchedData);
    }
  }, [watchedData, enabled, debouncedSave]);

  useEffect(() => {
    return () => {
      debouncedSave.cancel();
    };
  }, [debouncedSave]);
};
```

## 📊 **Advanced Form Features**

### **Multi-Step Form Component**
```typescript
// src/components/forms/MultiStepForm/MultiStepForm.tsx
import React, { useState } from 'react';
import {
  Box,
  Stepper,
  Step,
  StepLabel,
  Button,
  Typography,
} from '@mui/material';
import { useForm } from '../../../hooks/useForm';

interface MultiStepFormProps {
  steps: {
    label: string;
    component: React.ComponentType<any>;
    validation?: any;
  }[];
  onSubmit: (data: any) => Promise<void>;
  initialData?: any;
}

export const MultiStepForm: React.FC<MultiStepFormProps> = ({
  steps,
  onSubmit,
  initialData = {},
}) => {
  const [activeStep, setActiveStep] = useState(0);
  const [formData, setFormData] = useState(initialData);

  const currentStep = steps[activeStep];
  const isLastStep = activeStep === steps.length - 1;

  const {
    control,
    handleSubmit,
    trigger,
    formState: { isValid },
  } = useForm({
    schema: currentStep.validation,
    defaultValues: formData,
    onSubmit: async (data) => {
      const updatedData = { ...formData, ...data };
      setFormData(updatedData);

      if (isLastStep) {
        await onSubmit(updatedData);
      } else {
        setActiveStep(activeStep + 1);
      }
    },
  });

  const handleBack = () => {
    setActiveStep(activeStep - 1);
  };

  const handleNext = async () => {
    const isStepValid = await trigger();
    if (isStepValid) {
      handleSubmit();
    }
  };

  const CurrentStepComponent = currentStep.component;

  return (
    <Box>
      <Stepper activeStep={activeStep} sx={{ mb: 4 }}>
        {steps.map((step, index) => (
          <Step key={index}>
            <StepLabel>{step.label}</StepLabel>
          </Step>
        ))}
      </Stepper>

      <Box sx={{ mb: 4 }}>
        <CurrentStepComponent control={control} />
      </Box>

      <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
        <Button
          disabled={activeStep === 0}
          onClick={handleBack}
          variant="outlined"
        >
          Back
        </Button>
        
        <Button
          onClick={isLastStep ? handleSubmit : handleNext}
          variant="contained"
          disabled={!isValid}
        >
          {isLastStep ? 'Submit' : 'Next'}
        </Button>
      </Box>
    </Box>
  );
};
```

### **Form Field Array Component**
```typescript
// src/components/forms/FieldArray/DynamicFieldArray.tsx
import React from 'react';
import { useFieldArray, Control } from 'react-hook-form';
import { Box, Button, IconButton, Typography } from '@mui/material';
import { Add, Delete } from '@mui/icons-material';

interface DynamicFieldArrayProps {
  name: string;
  control: Control<any>;
  renderField: (index: number) => React.ReactNode;
  label: string;
  maxItems?: number;
  minItems?: number;
}

export const DynamicFieldArray: React.FC<DynamicFieldArrayProps> = ({
  name,
  control,
  renderField,
  label,
  maxItems = 10,
  minItems = 1,
}) => {
  const { fields, append, remove } = useFieldArray({
    control,
    name,
  });

  const canAdd = fields.length < maxItems;
  const canRemove = fields.length > minItems;

  return (
    <Box>
      <Typography variant="h6" gutterBottom>
        {label}
      </Typography>
      
      {fields.map((field, index) => (
        <Box
          key={field.id}
          sx={{
            display: 'flex',
            alignItems: 'center',
            gap: 2,
            mb: 2,
          }}
        >
          <Box sx={{ flexGrow: 1 }}>
            {renderField(index)}
          </Box>
          
          {canRemove && (
            <IconButton
              onClick={() => remove(index)}
              color="error"
              size="small"
            >
              <Delete />
            </IconButton>
          )}
        </Box>
      ))}
      
      {canAdd && (
        <Button
          onClick={() => append({})}
          startIcon={<Add />}
          variant="outlined"
          size="small"
        >
          Add {label.slice(0, -1)}
        </Button>
      )}
    </Box>
  );
};
```

---

## 📚 **Reference Documents**

**UI Components**: See `/5_frontend_implementation/1_ui_component_development.md`
**User Interface**: See `/5_frontend_implementation/2_user_interface_implementation.md`
**State Management**: See `/5_frontend_implementation/4_state_management_implementation.md`
**Frontend Specifications**: See `/frontend-specifications/form-specifications.md`

*This form handling and validation system provides comprehensive dynamic form capabilities for the ZbInnovation platform.*
