import { Service } from 'typedi';
import { PendingPushNotificationJob } from '@interfaces/pushNotifcationJob.interface';
import sendApiRequest from '@utils/axios';
@Service()
export class ExpoPushServerService {
  async sendPushNotification(job: PendingPushNotificationJob) {
    const data = JSON.stringify({
      data: job.data,
      title: job.title,
      ttl: job.ttl,
      priority: job.priority,
      to: job.push_token,
      mutableContent: job.mutable_content,
    });

    const axiosConfig = {
      method: 'POST',
      url: 'https://exp.host/--/api/v2/push/send',
      data,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    sendApiRequest(axiosConfig)
      .then(result => result)
      .catch(error => error);
  }
}
