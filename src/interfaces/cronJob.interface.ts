export interface CronJobs {
  schedule: string;
  callback: () => void;
}
