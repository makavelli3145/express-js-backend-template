export interface Alert {
  triggering_device_id: number;
  time;
  location: string;
  id?: number;
  status_id: number;
  message?: string;
  type_id: number;
}
