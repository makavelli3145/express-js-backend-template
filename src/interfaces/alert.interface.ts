export interface Alert {
  device_uuid: string;
  time?: number;
  location: string;
  id?: number;
  status_id: number;
  message?: string;
  type_id: number;
  alert_scheduled_time?: string;
  recurring_alert_end_user_id?: number;
  users_responded?: {
    username: string;
    response_time: string;
  }[];
  users_seen?: {
    username: string;
    seen_time: string;
  }[];
}
