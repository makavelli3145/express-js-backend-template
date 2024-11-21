import { Service } from 'typedi';
import pg from '@database';
import { Group } from '@interfaces/group.interface';
import { Alert } from '@interfaces/alert.interface';
import {CreateAlertDto} from "@dtos/alert.dto";

@Service()
export class AlertService {
  public createAlert = async (alert: CreateAlertDto): Promise<Group | boolean | NodeJS.ErrnoException> => {
    const { device_uuid, location } = alert;
    const sql = `INSERT INTO alerts (triggering_device_id, location) VALUES ( (SELECT id FROM devices WHERE device_uuid=$1), $2) RETURNING *;`;
    return await pg
      .query(sql, [device_uuid, location])
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

  async getAlertByUserId(userId: number, groupId: number):Promise<Group | boolean | NodeJS.ErrnoException> {
    const sql = `SELECT alerts.* FROM alerts
               JOIN devices ON  device.id = alerts.trigerring_device_id
               JOIN users ON  users.id = devices.user_id
               WHERE devices.user_id = $1 and groups.id = $2 ;`;


    return await pg
      .query(sql, [userId, groupId])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        } else {
          return false;
        }
      })
      .catch(err => err);
  }

  async getAlertByGroupId(groupId: number):Promise<Group | boolean | NodeJS.ErrnoException> {
    // const sql = 'SELECT\n' +
    //   '  alerts.id AS alert_id,\n' +
    //   '  alerts.time AS alert_time,\n' +
    //   '  push_notifications.id AS notification_id,\n' +
    //   '  push_notifications.message AS notification_message\n' +
    //   'FROM\n' +
    //   '  alerts\n' +
    //   '  LEFT JOIN push_notifications ON alerts.push_notifications_id = push_notifications.id;';
    //

    console.log("Dynamic URL works")
    return false;
  }

  async getAllAlerts(user_id: number) {
    console.log("Dynamic URL works")
    return false;
  }
}
