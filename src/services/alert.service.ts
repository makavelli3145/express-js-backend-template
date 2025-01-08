import { Service } from 'typedi';
import pg from '@database';
import { Group } from '@interfaces/group.interface';
import { Alert } from '@interfaces/alert.interface';

@Service()
export class AlertService {
  public createAlert = async (alert): Promise<Group | boolean | NodeJS.ErrnoException> => {
    const { triggering_device_id, location, status_id, type_id } = alert;
    const sql = `INSERT INTO alerts (triggering_device_id, location, status_id, type_id) VALUES ( (SELECT id FROM devices WHERE device_uuid=$1), $2, $3, $4) RETURNING *;`;
    return await pg
      .query(sql, [triggering_device_id, location, status_id, type_id])
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
    const { status_id, type_id, id } = alert;
    const sql = `
      UPDATE alerts SET status_id=$1, type_id=$2 WHERE id = $3 RETURNING *;`;
    return await pg
      .query(sql, [status_id, type_id, id])
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
    const sql = `Delete FROM alerts where id = $1 RETURNING *;`;
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

  async getAlertByUserId(userId: number, groupId: number): Promise<Group | boolean | NodeJS.ErrnoException> {
    const sql = `SELECT alerts.*, alerts_status.status as status,
                        users.name as user_name,
                        groups.name as group_name
               FROM alerts
               JOIN alerts_type on alerts.type_id = alerts_type.id
               JOIN alerts_status on alerts.status_id = alerts_status.id
               JOIN devices ON devices.id = alerts.triggering_device_id
               JOIN users ON users.id = devices.user_id
               JOIN users_groups ON users_groups.user_id = devices.user_id
               JOIN groups ON users_groups.group_id = groups.id
               WHERE devices.user_id = $1 and users_groups.group_id = $2 ;`;

    return await pg
      .query(sql, [userId, groupId])
      .then(result => {
        return result.rows;
      })
      .catch(err => err);
  }

  async getAlertByGroupId(groupId: number): Promise<Group | boolean | NodeJS.ErrnoException> {
    const sql = `SELECT alerts.*, alerts_status.status as status,
                        users.name as user_name,
                        groups.name as group_name
                 FROM alerts
                        JOIN alerts_type on alerts.type_id = alerts_type.id
                        JOIN alerts_status on alerts.status_id = alerts_status.id
                        JOIN devices ON devices.id = alerts.triggering_device_id
                        JOIN users ON users.id = devices.user_id
                        JOIN users_groups ON users_groups.user_id = users.id
                        JOIN groups ON users_groups.group_id = groups.id
                WHERE users_groups.group_id = $1;`;

    return await pg
      .query(sql, [groupId])
      .then(result => {
        return result.rows;
      })
      .catch(err => err);
  }

  async getAllAlerts(user_id: number) {
    const sql = `SELECT DISTINCT alerts.id as id,
                                 alerts.time,
                                 alerts.location,
                                 alerts.message,
                                 alerts_status.status as status,
                                 alerts_type.type as type,
                                 u.name as user_name,
                                 groups.name as group_name
                                 FROM alerts
                                        JOIN alerts_type on alerts.type_id = alerts_type.id
                                        JOIN alerts_status on alerts.status_id = alerts_status.id
                                        JOIN devices ON alerts.triggering_device_id = devices.id
                                        JOIN users_groups ON devices.user_id = users_groups.user_id
                                        JOIN users as u on users_groups.user_id = u.id
                                        JOIN ( SELECT * FROM users_groups WHERE user_id = $1 ) g_id ON g_id.group_id = users_groups.group_id
                                        JOIN groups on g_id.group_id = groups.id;`;

    return await pg
      .query(sql, [user_id])
      .then(result => {
        return result.rows;
      })
      .catch(err => err);
  }
}
