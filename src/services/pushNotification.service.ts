import { Service } from 'typedi';
import pg from '@database';
import { Group } from '@interfaces/group.interface';
import { PushNotification } from '@interfaces/pushNotification.interfact';
import { Device } from '@interfaces/device.interface';

@Service()
export class PushNotificationService {
  public createPushNotification = async (group: Group, pushNotification: PushNotification, device: Device) => {
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
      INSERT INTO push_notifications (to_device_id, data, title, body, push_notifications_type_id) VALUES ${valueString};
    `;
  };
}
