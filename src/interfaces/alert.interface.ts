export interface Alert {
  device_uuid: string;
  time?: number;
  location: string;
  id?: number;
  status_id: number;
  message?: string;
  type_id: number;
}
