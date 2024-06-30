import { CronJobs } from '@interfaces/cronJob.interface';
import { PushNotificationsCron } from '@/cron/pushNotifications.cron';

export class InitCronJobs {
  private pushNotificationsCron = new PushNotificationsCron();
  public initializeJobs(): CronJobs[] {
    return [
      {
        schedule: '* * * * *',
        callback: () => {
          this.pushNotificationsCron.processPushNotificationsJob(0);
        },
      },
      {
        schedule: '*/5 * * * *',
        callback: () => {
          this.pushNotificationsCron.processPushNotificationsJob(1);
        },
      },
      {
        schedule: '*/10 * * * *',
        callback: () => {
          this.pushNotificationsCron.processPushNotificationsJob(2);
        },
      },
    ];
  }
}
