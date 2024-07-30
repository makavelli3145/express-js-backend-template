import { Container } from 'typedi';
import { PushNotificationService } from '@services/pushNotification.service';
import { ExpoPushServerService } from '@services/expoPushServer.service';
import { PendingPushNotificationJob } from '@interfaces/pushNotifcationJob.interface';

export class PushNotificationsCron {
  private pushNotifications = Container.get(PushNotificationService);
  private expoPushServer = Container.get(ExpoPushServerService);
  public processPushNotificationsJob(priority: number) {
    this.pushNotifications.getPendingJobs(priority).then(result => {
      if (Array.isArray(result)) {
        result.forEach(job => {
          this.expoPushServer
            .sendPushNotification(job)
            .then(() => {
              this.resolvePushNotificationResponse(job);
            })
            .catch(error => {
              this.resolvePushNotificationErrorResponse(job, error.method);
            });
        });
      }
    });
  }

  private resolvePushNotificationResponse(job: PendingPushNotificationJob) {
    try {
      this.pushNotifications.completePendingJob(job);
    } catch (error) {
      this.pushNotifications.failPendingJob(job, error.message);
    }
  }

  private resolvePushNotificationErrorResponse(job: PendingPushNotificationJob, error: string) {
    if (job.retry_attempt < 5) {
      this.pushNotifications.incrementRetryAttempt(job);
    } else {
      this.pushNotifications.failPendingJob(job, error);
    }
  }
}
