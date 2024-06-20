import { Service } from 'typedi';
import pg from '@database';
import { Group } from '@interfaces/group.interface';
import { PushNotification } from '@interfaces/pushNotification.interface';
import { Device } from '@interfaces/device.interface';
import { PendingPushNotificationJob, PushNotificationJob } from '@interfaces/pushNotifcationJob.interface';

@Service()
export class PushNotificationService {
  public createPushNotification = async (
    group: Group,
    pushNotification: PushNotification,
    device: Device,
  ): Promise<PushNotification[] | Boolean | NodeJS.ErrnoException> => {
    const { id } = group;
    const { title, body, data, push_notification_type_id } = pushNotification;
    let sql = 'SELECt name from push_notification_type where id = $1';
    let values = [push_notification_type_id];
    return await pg
      .query(sql, values)
      .then(async result => {
        if (result.rowCount > 0) {
          const pushNotificationName = result.rows[0].name;
          switch (pushNotificationName) {
            case pushNotificationName === 'emergency alert':
              sql = this.getPushTokensForAllUsersInGroup();
              values = [id];
              break;
            case pushNotificationName === 'wake device':
              sql = this.getPushTokenForDevice();
              values = [device.id];
              break;
            case pushNotificationName === 'checkin':
              sql = this.getPushTokenForDevice();
              values = [device.id];
              break;
          }
          return await pg
            .query(sql, values)
            .then(async result => {
              if (result.rowCount > 0) {
                const pushTokens: string[] = result.rows.map(row => row.push_token);
                sql = this.insertPushNotifications(pushTokens.length);
                let values = [];
                pushTokens.forEach(token => {
                  let valuesItemArray = [token, data, title, body, push_notification_type_id];
                  values = [...values, ...valuesItemArray];
                });
                return await pg.query(sql, values).then(result => {
                  if (result.rowCount > 0) {
                    return result.rows;
                  } else {
                    return false;
                  }
                });
              } else {
                return false;
              }
            })
            .catch(error => error);
        } else {
          return false;
        }
      })
      .catch(error => error);
  };

  private getPushTokenForDevice = () => {
    return `
      SELECT
        push_token
          FROM
            devices
              WHERE
                id = $1
    `;
  };

  private getPushTokensForAllUsersInGroup = () => {
    return `
      SELECT
        push_token
        FROM
          devices
            JOIN users_groups on
              users_groups.user_id = devices.user_id
                AND
                  users_groups.group_id = $1;`;
  };

  private insertPushNotifications = (valueCount: number) => {
    let valuesArray = [];
    for (let i = 0; i < valueCount; i++) {
      const value_1 = 1 + i * 5;
      const value_2 = 2 + i * 5;
      const value_3 = 3 + i * 5;
      const value_4 = 4 + i * 5;
      const value_5 = 5 + i * 5;
      valuesArray.push(`($${value_1}, $${value_2}, $${value_3}, $${value_4}, $${value_5})`);
    }
    const valueString = valuesArray.join(',');
    return `
      INSERT
      INTO push_notifications (to_device_id, data, title, body, push_notifications_type_id)
      VALUES ${valueString};
    `;
  };

  private insertPushNotificationJobs = (savedPushNotifcations, priority: number) => {
    let valuesArray = [];
    let valueCount = savedPushNotifcations.length;
    for (let i = 0; i < valueCount; i++) {
      const value_1 = 1 + i * 2;
      const value_2 = 2 + i * 2;
      valuesArray.push(`($${value_1}, $${value_2})`);
    }
    const valueString = valuesArray.join(',');
    return `
      INSERT
      INTO push_notification_jobs (push_id, priority)
      VALUES ${valueString};
    `;
  };

  async createPushNotificationJob(savedPushNotifications: PushNotification[]): Promise<PushNotificationJob[] | boolean | NodeJS.ErrnoException> {
    let priority = 0;
    const sql = this.insertPushNotificationJobs(savedPushNotifications, priority);
    let values = [];
    savedPushNotifications.forEach(item => {
      values = [...values, item.id, priority];
    });
    return await pg
      .query(sql, values)
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows;
        } else {
          return false;
        }
      })
      .catch(error => error);
  }

  async getPendingJobs(priority: number): Promise<PendingPushNotificationJob[] | boolean | NodeJS.ErrnoException> {
    const sql = `
      SELECT
        push_notification_jobs.id,
        data,
        title,
        body,
        name,
        ttl,
        priority,
        mutable_content,
        push_token,
        retry_attempt
          FROM push_notification_jobs
            join push_notifications
                on push_notification_jobs.push_id = push_notifications.id
            join push_notification_type
                on push_notifications.push_notification_type_id = push_notification_type.id
            join devices
                on push_notifications.to_device_id = devices.id
            where push_notification_jobs.pending = true and push_notification_type.priority=$1;`;

    return await pg
      .query(sql, [priority])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows;
        } else {
          return false;
        }
      })
      .catch(error => error);
  }

  async completePendingJob(pendingPushNotificationJob: PendingPushNotificationJob): Promise<PushNotificationJob[] | boolean | NodeJS.ErrnoException> {
    const { id } = pendingPushNotificationJob;
    const sql = `UPDATE push_notification_jobs SET pending = false, completed=true WHERE id = $1`;
    return await pg
      .query(sql, [id])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows;
        } else {
          return false;
        }
      })
      .catch(error => error);
  }

  async failPendingJob(
    pendingPushNotificationJob: PendingPushNotificationJob,
    error: string | null = null,
  ): Promise<PushNotificationJob[] | boolean | NodeJS.ErrnoException> {
    const { id } = pendingPushNotificationJob;
    const sql = `
        UPDATE push_notification_jobs
            SET
                pending = false,
                failed = true,
                error=$2
            WHERE id = $1`;
    return await pg
      .query(sql, [id, error])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows;
        } else {
          return false;
        }
      })
      .catch(error => error);
  }

  async incrementRetryAttempt(
    pendingPushNotificationJob: PendingPushNotificationJob,
  ): Promise<PushNotificationJob | boolean | NodeJS.ErrnoException> {
    const { id, retry_attempt } = pendingPushNotificationJob;
    const sql = `
      UPDATE push_notification_jobs SET retry_attempt = $1 WHERE id = $2;
    `;
    const retry_value = retry_attempt + 1;
    return await pg
      .query(sql, [retry_value, id])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        } else {
          return false;
        }
      })
      .catch(error => error);
  }
}
