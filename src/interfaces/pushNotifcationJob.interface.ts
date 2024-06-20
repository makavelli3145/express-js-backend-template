export interface PushNotificationJob {
  completed: boolean;
  pending: boolean;
  failed: boolean;
  error: string;
  completed_at: string;
  created_at: string;
  retry_attempt: number;
  priority: number;
  push_id: number;
  id?: number;
}

export interface PendingPushNotificationJob {
  id: number;
  data: object;
  title: string;
  body: string;
  ttl: number;
  priority: number;
  mutable_content: boolean;
  push_token: string;
  name: string;
  retry_attempt: number;
}
