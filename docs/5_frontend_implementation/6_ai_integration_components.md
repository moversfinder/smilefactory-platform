# 6. AI Integration Components

## 🤖 **AI Integration Frontend Overview**

This document outlines the comprehensive frontend implementation of AI integration components for the ZbInnovation platform, including the AI chat interface, trigger buttons, streaming responses, context-aware suggestions, and profile-specific AI assistance.

## 🎨 **AI Chat Interface Component**

### **Main AI Chat Component**
```typescript
// src/components/ai/AIChatInterface.tsx
import React, { useState, useRef, useEffect } from 'react';
import {
  Box,
  Paper,
  TextField,
  IconButton,
  Typography,
  Chip,
  CircularProgress,
  Fade,
  Slide,
} from '@mui/material';
import {
  Send as SendIcon,
  Close as CloseIcon,
  Minimize as MinimizeIcon,
  SmartToy as AIIcon,
} from '@mui/icons-material';
import { useAIChat } from '../../hooks/useAIChat';
import { useAuth } from '../../hooks/useAuth';
import { AIMessage } from './AIMessage';
import { QuickReplies } from './QuickReplies';
import { AITypingIndicator } from './AITypingIndicator';

interface AIChatInterfaceProps {
  isOpen: boolean;
  onClose: () => void;
  onMinimize: () => void;
  initialMessage?: string;
  currentPage?: string;
  pageContext?: Record<string, any>;
  position?: 'bottom-right' | 'bottom-left' | 'center';
}

export const AIChatInterface: React.FC<AIChatInterfaceProps> = ({
  isOpen,
  onClose,
  onMinimize,
  initialMessage,
  currentPage,
  pageContext,
  position = 'bottom-right',
}) => {
  const { user } = useAuth();
  const [message, setMessage] = useState(initialMessage || '');
  const [isMinimized, setIsMinimized] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  
  const {
    messages,
    isLoading,
    isStreaming,
    quickReplies,
    suggestions,
    sendMessage,
    clearConversation,
    conversationId,
  } = useAIChat({
    userId: user?.id,
    currentPage,
    pageContext,
  });

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  useEffect(() => {
    if (initialMessage && isOpen) {
      handleSendMessage(initialMessage);
      setMessage('');
    }
  }, [initialMessage, isOpen]);

  const handleSendMessage = async (messageText?: string) => {
    const textToSend = messageText || message;
    if (!textToSend.trim()) return;

    await sendMessage(textToSend);
    setMessage('');
  };

  const handleQuickReply = (reply: string) => {
    handleSendMessage(reply);
  };

  const handleKeyPress = (event: React.KeyboardEvent) => {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      handleSendMessage();
    }
  };

  const handleMinimize = () => {
    setIsMinimized(!isMinimized);
    onMinimize();
  };

  if (!isOpen) return null;

  const positionStyles = {
    'bottom-right': {
      position: 'fixed' as const,
      bottom: 20,
      right: 20,
      zIndex: 1300,
    },
    'bottom-left': {
      position: 'fixed' as const,
      bottom: 20,
      left: 20,
      zIndex: 1300,
    },
    'center': {
      position: 'fixed' as const,
      top: '50%',
      left: '50%',
      transform: 'translate(-50%, -50%)',
      zIndex: 1300,
    },
  };

  return (
    <Slide direction="up" in={isOpen} mountOnEnter unmountOnExit>
      <Paper
        elevation={8}
        sx={{
          ...positionStyles[position],
          width: isMinimized ? 300 : 400,
          height: isMinimized ? 60 : 600,
          display: 'flex',
          flexDirection: 'column',
          borderRadius: 2,
          overflow: 'hidden',
          transition: 'all 0.3s ease-in-out',
        }}
      >
        {/* Header */}
        <Box
          sx={{
            p: 2,
            bgcolor: 'primary.main',
            color: 'primary.contrastText',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <AIIcon />
            <Typography variant="h6" sx={{ fontSize: '1rem' }}>
              AI Assistant
            </Typography>
            {conversationId && (
              <Chip
                label="Active"
                size="small"
                sx={{
                  bgcolor: 'success.main',
                  color: 'success.contrastText',
                  fontSize: '0.75rem',
                }}
              />
            )}
          </Box>
          <Box>
            <IconButton
              size="small"
              onClick={handleMinimize}
              sx={{ color: 'inherit', mr: 1 }}
            >
              <MinimizeIcon />
            </IconButton>
            <IconButton
              size="small"
              onClick={onClose}
              sx={{ color: 'inherit' }}
            >
              <CloseIcon />
            </IconButton>
          </Box>
        </Box>

        {!isMinimized && (
          <>
            {/* Messages Area */}
            <Box
              sx={{
                flex: 1,
                overflow: 'auto',
                p: 1,
                display: 'flex',
                flexDirection: 'column',
                gap: 1,
              }}
            >
              {messages.length === 0 && (
                <Box
                  sx={{
                    display: 'flex',
                    flexDirection: 'column',
                    alignItems: 'center',
                    justifyContent: 'center',
                    height: '100%',
                    textAlign: 'center',
                    p: 2,
                  }}
                >
                  <AIIcon sx={{ fontSize: 48, color: 'primary.main', mb: 2 }} />
                  <Typography variant="h6" gutterBottom>
                    Hi {user?.firstName}! 👋
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    I'm your AI assistant for ZbInnovation. How can I help you today?
                  </Typography>
                </Box>
              )}

              {messages.map((msg, index) => (
                <AIMessage
                  key={index}
                  message={msg}
                  isUser={msg.role === 'user'}
                  isStreaming={isStreaming && index === messages.length - 1}
                />
              ))}

              {isLoading && <AITypingIndicator />}

              <div ref={messagesEndRef} />
            </Box>

            {/* Quick Replies */}
            {quickReplies.length > 0 && (
              <Box sx={{ p: 1, borderTop: 1, borderColor: 'divider' }}>
                <QuickReplies
                  replies={quickReplies}
                  onReplyClick={handleQuickReply}
                />
              </Box>
            )}

            {/* Input Area */}
            <Box
              sx={{
                p: 2,
                borderTop: 1,
                borderColor: 'divider',
                display: 'flex',
                gap: 1,
                alignItems: 'flex-end',
              }}
            >
              <TextField
                fullWidth
                multiline
                maxRows={3}
                placeholder="Ask me anything..."
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                onKeyPress={handleKeyPress}
                disabled={isLoading}
                variant="outlined"
                size="small"
                sx={{
                  '& .MuiOutlinedInput-root': {
                    borderRadius: 2,
                  },
                }}
              />
              <IconButton
                color="primary"
                onClick={() => handleSendMessage()}
                disabled={!message.trim() || isLoading}
                sx={{
                  bgcolor: 'primary.main',
                  color: 'primary.contrastText',
                  '&:hover': {
                    bgcolor: 'primary.dark',
                  },
                  '&:disabled': {
                    bgcolor: 'action.disabled',
                  },
                }}
              >
                {isLoading ? (
                  <CircularProgress size={20} color="inherit" />
                ) : (
                  <SendIcon />
                )}
              </IconButton>
            </Box>
          </>
        )}
      </Paper>
    </Slide>
  );
};
```

### **AI Message Component**
```typescript
// src/components/ai/AIMessage.tsx
import React from 'react';
import {
  Box,
  Typography,
  Avatar,
  Paper,
  Chip,
  IconButton,
  Tooltip,
} from '@mui/material';
import {
  SmartToy as AIIcon,
  Person as UserIcon,
  ThumbUp as ThumbUpIcon,
  ThumbDown as ThumbDownIcon,
  ContentCopy as CopyIcon,
} from '@mui/icons-material';
import { formatDistanceToNow } from 'date-fns';
import { useAuth } from '../../hooks/useAuth';

interface AIMessageProps {
  message: {
    id: string;
    role: 'user' | 'assistant';
    content: string;
    timestamp: string;
    suggestions?: string[];
    metadata?: Record<string, any>;
  };
  isUser: boolean;
  isStreaming?: boolean;
}

export const AIMessage: React.FC<AIMessageProps> = ({
  message,
  isUser,
  isStreaming,
}) => {
  const { user } = useAuth();

  const handleCopyMessage = () => {
    navigator.clipboard.writeText(message.content);
  };

  const handleFeedback = (rating: 'positive' | 'negative') => {
    // Send feedback to API
    console.log('Feedback:', rating, message.id);
  };

  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: isUser ? 'row-reverse' : 'row',
        gap: 1,
        mb: 2,
      }}
    >
      <Avatar
        sx={{
          bgcolor: isUser ? 'primary.main' : 'secondary.main',
          width: 32,
          height: 32,
        }}
      >
        {isUser ? <UserIcon /> : <AIIcon />}
      </Avatar>

      <Box sx={{ flex: 1, maxWidth: '80%' }}>
        <Paper
          elevation={1}
          sx={{
            p: 2,
            bgcolor: isUser ? 'primary.light' : 'background.paper',
            color: isUser ? 'primary.contrastText' : 'text.primary',
            borderRadius: 2,
            position: 'relative',
          }}
        >
          <Typography
            variant="body1"
            sx={{
              whiteSpace: 'pre-wrap',
              wordBreak: 'break-word',
            }}
          >
            {message.content}
            {isStreaming && (
              <Box
                component="span"
                sx={{
                  display: 'inline-block',
                  width: 8,
                  height: 16,
                  bgcolor: 'currentColor',
                  ml: 0.5,
                  animation: 'blink 1s infinite',
                  '@keyframes blink': {
                    '0%, 50%': { opacity: 1 },
                    '51%, 100%': { opacity: 0 },
                  },
                }}
              />
            )}
          </Typography>

          {/* Message Actions */}
          {!isUser && !isStreaming && (
            <Box
              sx={{
                display: 'flex',
                gap: 0.5,
                mt: 1,
                opacity: 0.7,
                '&:hover': { opacity: 1 },
              }}
            >
              <Tooltip title="Copy message">
                <IconButton size="small" onClick={handleCopyMessage}>
                  <CopyIcon fontSize="small" />
                </IconButton>
              </Tooltip>
              <Tooltip title="Helpful">
                <IconButton
                  size="small"
                  onClick={() => handleFeedback('positive')}
                >
                  <ThumbUpIcon fontSize="small" />
                </IconButton>
              </Tooltip>
              <Tooltip title="Not helpful">
                <IconButton
                  size="small"
                  onClick={() => handleFeedback('negative')}
                >
                  <ThumbDownIcon fontSize="small" />
                </IconButton>
              </Tooltip>
            </Box>
          )}
        </Paper>

        {/* Suggestions */}
        {message.suggestions && message.suggestions.length > 0 && (
          <Box sx={{ mt: 1, display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
            {message.suggestions.map((suggestion, index) => (
              <Chip
                key={index}
                label={suggestion}
                size="small"
                variant="outlined"
                clickable
                onClick={() => {
                  // Handle suggestion click
                  console.log('Suggestion clicked:', suggestion);
                }}
              />
            ))}
          </Box>
        )}

        {/* Timestamp */}
        <Typography
          variant="caption"
          color="text.secondary"
          sx={{ display: 'block', mt: 0.5, textAlign: isUser ? 'right' : 'left' }}
        >
          {formatDistanceToNow(new Date(message.timestamp), { addSuffix: true })}
        </Typography>
      </Box>
    </Box>
  );
};
```

## 🎯 **AI Trigger Buttons Component**

### **Profile-Specific AI Triggers**
```typescript
// src/components/ai/AITriggerButtons.tsx
import React from 'react';
import {
  Box,
  Button,
  Card,
  CardContent,
  Typography,
  Grid,
  Chip,
  IconButton,
  Tooltip,
} from '@mui/material';
import {
  SmartToy as AIIcon,
  TrendingUp as TrendingIcon,
  People as PeopleIcon,
  School as SchoolIcon,
  Business as BusinessIcon,
  Event as EventIcon,
  Search as SearchIcon,
} from '@mui/icons-material';
import { useAuth } from '../../hooks/useAuth';
import { useAITriggers } from '../../hooks/useAITriggers';

interface AITriggerButtonsProps {
  currentPage: string;
  onTriggerClick: (prompt: string, title: string) => void;
  compact?: boolean;
}

export const AITriggerButtons: React.FC<AITriggerButtonsProps> = ({
  currentPage,
  onTriggerClick,
  compact = false,
}) => {
  const { user } = useAuth();
  const { triggers, isLoading } = useAITriggers(user?.id, currentPage);

  const getIconForCategory = (category: string) => {
    const iconMap = {
      funding: <TrendingIcon />,
      team: <PeopleIcon />,
      mentorship: <SchoolIcon />,
      investment: <BusinessIcon />,
      networking: <PeopleIcon />,
      discovery: <SearchIcon />,
      events: <EventIcon />,
    };
    return iconMap[category] || <AIIcon />;
  };

  if (isLoading || triggers.length === 0) {
    return null;
  }

  if (compact) {
    return (
      <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
        {triggers.slice(0, 3).map((trigger) => (
          <Tooltip key={trigger.id} title={trigger.description}>
            <Button
              variant="outlined"
              size="small"
              startIcon={getIconForCategory(trigger.category)}
              onClick={() => onTriggerClick(trigger.prompt, trigger.title)}
              sx={{
                borderRadius: 2,
                textTransform: 'none',
                fontSize: '0.875rem',
              }}
            >
              {trigger.title}
            </Button>
          </Tooltip>
        ))}
      </Box>
    );
  }

  return (
    <Box sx={{ mb: 3 }}>
      <Typography variant="h6" gutterBottom sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <AIIcon color="primary" />
        AI Assistance for {user?.profileType?.replace('_', ' ')}
      </Typography>
      
      <Grid container spacing={2}>
        {triggers.map((trigger) => (
          <Grid item xs={12} sm={6} md={4} key={trigger.id}>
            <Card
              sx={{
                cursor: 'pointer',
                transition: 'all 0.2s ease-in-out',
                '&:hover': {
                  transform: 'translateY(-2px)',
                  boxShadow: 4,
                },
              }}
              onClick={() => onTriggerClick(trigger.prompt, trigger.title)}
            >
              <CardContent sx={{ p: 2 }}>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                  <Box
                    sx={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      width: 32,
                      height: 32,
                      borderRadius: 1,
                      bgcolor: 'primary.light',
                      color: 'primary.main',
                    }}
                  >
                    {getIconForCategory(trigger.category)}
                  </Box>
                  <Typography variant="h6" sx={{ fontSize: '1rem', fontWeight: 600 }}>
                    {trigger.title}
                  </Typography>
                </Box>
                
                <Typography
                  variant="body2"
                  color="text.secondary"
                  sx={{ mb: 1, lineHeight: 1.4 }}
                >
                  {trigger.description}
                </Typography>
                
                <Chip
                  label={trigger.category}
                  size="small"
                  variant="outlined"
                  sx={{ textTransform: 'capitalize' }}
                />
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>
    </Box>
  );
};
```

## 🔗 **AI Integration Hooks**

### **useAIChat Hook**
```typescript
// src/hooks/useAIChat.ts
import { useState, useCallback, useRef } from 'react';
import { useQuery, useMutation } from '@tanstack/react-query';
import { apiClient } from '../services/apiClient';

interface UseAIChatOptions {
  userId?: string;
  currentPage?: string;
  pageContext?: Record<string, any>;
}

interface AIMessage {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: string;
  suggestions?: string[];
  metadata?: Record<string, any>;
}

interface QuickReply {
  id: string;
  text: string;
  action?: string;
  icon?: string;
}

export const useAIChat = (options: UseAIChatOptions) => {
  const [messages, setMessages] = useState<AIMessage[]>([]);
  const [conversationId, setConversationId] = useState<string | null>(null);
  const [isStreaming, setIsStreaming] = useState(false);
  const [quickReplies, setQuickReplies] = useState<QuickReply[]>([]);
  const [suggestions, setSuggestions] = useState<string[]>([]);
  const abortControllerRef = useRef<AbortController | null>(null);

  const sendMessageMutation = useMutation({
    mutationFn: async (message: string) => {
      // Cancel any ongoing request
      if (abortControllerRef.current) {
        abortControllerRef.current.abort();
      }

      abortControllerRef.current = new AbortController();

      // Add user message immediately
      const userMessage: AIMessage = {
        id: Date.now().toString(),
        role: 'user',
        content: message,
        timestamp: new Date().toISOString(),
      };

      setMessages(prev => [...prev, userMessage]);
      setIsStreaming(true);
      setQuickReplies([]);
      setSuggestions([]);

      // Start streaming response
      const response = await fetch('/api/v1/ai/chat', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message,
          conversationId,
          currentPage: options.currentPage,
          pageContext: options.pageContext,
          includeContext: true,
        }),
        signal: abortControllerRef.current.signal,
      });

      if (!response.ok) {
        throw new Error('Failed to send message');
      }

      const reader = response.body?.getReader();
      if (!reader) {
        throw new Error('No response body');
      }

      let aiMessage: AIMessage = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: '',
        timestamp: new Date().toISOString(),
      };

      setMessages(prev => [...prev, aiMessage]);

      try {
        while (true) {
          const { done, value } = await reader.read();
          if (done) break;

          const chunk = new TextDecoder().decode(value);
          const lines = chunk.split('\n');

          for (const line of lines) {
            if (line.startsWith('data: ')) {
              const data = line.slice(6);
              if (data === '[DONE]') {
                setIsStreaming(false);
                return;
              }

              try {
                const parsed = JSON.parse(data);
                
                if (parsed.type === 'start') {
                  setConversationId(parsed.conversationId);
                } else if (parsed.type === 'content') {
                  aiMessage.content += parsed.content;
                  setMessages(prev => 
                    prev.map(msg => 
                      msg.id === aiMessage.id 
                        ? { ...msg, content: aiMessage.content }
                        : msg
                    )
                  );
                } else if (parsed.type === 'suggestions') {
                  setSuggestions(parsed.suggestions);
                } else if (parsed.type === 'quick_replies') {
                  setQuickReplies(parsed.quickReplies);
                }
              } catch (e) {
                console.warn('Failed to parse streaming data:', data);
              }
            }
          }
        }
      } finally {
        setIsStreaming(false);
      }
    },
  });

  const sendMessage = useCallback((message: string) => {
    return sendMessageMutation.mutateAsync(message);
  }, [sendMessageMutation]);

  const clearConversation = useCallback(() => {
    setMessages([]);
    setConversationId(null);
    setQuickReplies([]);
    setSuggestions([]);
    setIsStreaming(false);
  }, []);

  return {
    messages,
    conversationId,
    isLoading: sendMessageMutation.isPending,
    isStreaming,
    quickReplies,
    suggestions,
    sendMessage,
    clearConversation,
    error: sendMessageMutation.error,
  };
};
```

---

## 📚 **Reference Documents**

**AI Backend Implementation**: See `/4_backend_implementation/6_ai_integration_implementation.md`
**AI API Specifications**: See `/2_technical_architecture/api_specifications/4_ai_integration_apis.md`
**State Management**: See `/5_frontend_implementation/4_state_management_implementation.md`
**UI Component Development**: See `/5_frontend_implementation/1_ui_component_development.md`

*This comprehensive AI integration frontend implementation provides seamless AI-powered assistance with streaming responses, context awareness, and profile-specific features for the ZbInnovation platform.*
