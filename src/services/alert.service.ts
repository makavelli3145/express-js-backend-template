import { Service } from 'typedi';
import pg from '@database';
import { Group } from '@interfaces/group.interface';
import { Alert } from '@interfaces/alert.interface';

@Service()
export class AlertService {
  public createAlert = async (alert: Alert): Promise<Group | boolean | NodeJS.ErrnoException> => {
    const { triggering_device_id, location, push_notification_id, id } = alert;
    const sql = `INSERT INTO groups (triggering_device_id, location, push_notification_id, id) VALUES ( $1, $2, $3, $4) RETURNING *`;
    return await pg
      .query(sql, [triggering_device_id, location, push_notification_id, id])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        } else {
          return false;
        }
      })
      .catch(error => error);
  };

  public updateAlert = async (alert: Alert): Promise<Group | boolean | NodeJS.ErrnoException> => {
    const { triggering_device_id, location, push_notification_id, id } = alert;
    const sql = `
      UPDATE groups SET triggering_device_id = $1, location = $2, push_notification_id=$3 WHERE id = $4 RETURNING *;`;
    return await pg
      .query(sql, [triggering_device_id, location, push_notification_id, id])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        } else {
          return false;
        }
      })
      .catch(error => error);
  };

  async deleteAlert(alert: Alert): Promise<Group | boolean | NodeJS.ErrnoException> {
    const { id } = alert;
    const sql = `Delete FROM groups where id = $1 RETURNING *;`;
    return await pg
      .query(sql, [id])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        } else {
          return false;
        }
      })
      .catch(err => err);
  }
}
