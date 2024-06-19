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
