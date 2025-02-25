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
  users_responded?: string;
  users_seen?: string;
}
