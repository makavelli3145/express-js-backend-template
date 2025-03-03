import { Service } from 'typedi';
import pg from '@database';
import { Group } from '@interfaces/group.interface';
import { Alert } from '@interfaces/alert.interface';

@Service()
export class AlertService {
  public createAlertSeenBy = async (alertId: number, userId: number): Promise<{ alert_id: number; user_id: number } | boolean | NodeJS.ErrnoException> => {
    const sql = `INSERT INTO seen_by (alert_id, user_id)
                 VALUES ($1, $2)
                   ON CONFLICT (alert_id, user_id) DO NOTHING RETURNING *;`;

    try {
      const result = await pg.query(sql, [alertId, userId]);
      if (result.rowCount > 0) {
        return result.rows[0];
      }
      return false;
    } catch (error) {
      return error;
    }
  };


  public createAlertRespondedBy = async (alertId: number, userId: number): Promise<Alert | boolean | NodeJS.ErrnoException> => {
    const sql = `INSERT INTO responded_by (alert_id, user_id)
                 VALUES ($1, $2)
                   ON CONFLICT (alert_id, user_id) DO NOTHING RETURNING *;`;
    return await pg
      .query(sql, [alertId, userId])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        }
      })
  }

  public createAlert = async (alert: Alert): Promise<Group | boolean | NodeJS.ErrnoException> => {
    const { device_uuid, location, status_id, type_id , alert_scheduled_time, message, recurring_alert_end_user_id} = alert;
    const sql = `INSERT INTO alerts (triggering_device_id, location, status_id, type_id, alert_scheduled_time, message, recurring_alert_end_user_id) VALUES ( (SELECT id FROM devices WHERE device_uuid=$1), $2, $3, $4, $5, $6, $7) RETURNING *;`;
    return await pg
      .query(sql, [device_uuid, location, status_id, type_id,alert_scheduled_time, message, recurring_alert_end_user_id])
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
    const { status_id, type_id, alert_scheduled_time, message, id } = alert;
    if(alert_scheduled_time) {
      const sql = `
        UPDATE alerts
        SET status_id=$1,
            type_id=$2,
            alert_scheduled_time=$3,
            message=$4
        WHERE id = $5 RETURNING *;`;
      return await pg
        .query(sql, [status_id, type_id, alert_scheduled_time, message, id])
        .then(result => {
          if (result.rowCount > 0) {
            return result.rows[0];
          } else {
            return false;
          }
        })
        .catch(error => error);
    }else{
      const sql = `
        UPDATE alerts
        SET status_id=$1,
            type_id=$2
        WHERE id = $3 RETURNING *;`;
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

    }
  };

  async deleteAlert(alert: Alert): Promise<Alert | boolean | NodeJS.ErrnoException> {
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
    const sql = `SELECT alerts.*,
                        alerts_status.status as status,  -- Ensure this is in GROUP BY
                        users.name AS user_name,
                        groups.name AS group_name,
                        users.id as created_by_user_id,
                   COALESCE(
                          JSON_AGG(
                            DISTINCT JSONB_BUILD_OBJECT(
                                'name', users_responded.name,
                                'response_time', responded_by.time
                                 )
                                ) FILTER (WHERE users_responded.id IS NOT NULL), '[]'::JSON
                        ) AS users_responded,
                        COALESCE(
                          JSON_AGG(
                            DISTINCT JSONB_BUILD_OBJECT(
                                'name', users_seen.name,
                                'seen_time', seen_by.time
                                 )
                                ) FILTER (WHERE users_seen.id IS NOT NULL), '[]'::JSON
                        ) AS users_seen
                 FROM alerts
                        JOIN alerts_type on alerts.type_id = alerts_type.id
                        JOIN alerts_status on alerts.status_id = alerts_status.id
                        JOIN devices ON devices.id = alerts.triggering_device_id
                        JOIN users ON users.id = devices.user_id
                        JOIN users_groups ON users_groups.user_id = devices.user_id
                        JOIN groups ON users_groups.group_id = groups.id
                        LEFT JOIN responded_by ON responded_by.alert_id = alerts.id
                        LEFT JOIN users AS users_responded ON users_responded.id = responded_by.user_id
                        LEFT JOIN seen_by ON seen_by.alert_id = alerts.id
                        LEFT JOIN users AS users_seen ON users_seen.id = seen_by.user_id
                 WHERE users_groups.group_id = $2
                   AND alerts.recurring_alert_end_user_id = $1
                 GROUP BY alerts.id, alerts_status.status, users.name, users.id, groups.name;`;

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
                        groups.name as group_name,
                        users.id as created_by_user_id,
                        COALESCE(
                          JSON_AGG(
                            DISTINCT JSONB_BUILD_OBJECT(
                                'name', users_responded.name,
                                'response_time', responded_by.time
                                 )
                                ) FILTER (WHERE users_responded.id IS NOT NULL), '[]'::JSON
                        ) AS users_responded,
                        COALESCE(
                          JSON_AGG(
                            DISTINCT JSONB_BUILD_OBJECT(
                                'name', users_seen.name,
                                'seen_time', seen_by.time
                                 )
                                ) FILTER (WHERE users_seen.id IS NOT NULL), '[]'::JSON
                        ) AS users_seen
                 FROM alerts
                        JOIN alerts_type on alerts.type_id = alerts_type.id
                        JOIN alerts_status on alerts.status_id = alerts_status.id
                        JOIN devices ON devices.id = alerts.triggering_device_id
                        JOIN users ON users.id = devices.user_id
                        JOIN users_groups ON users_groups.user_id = users.id
                        JOIN groups ON users_groups.group_id = groups.id
                       LEFT JOIN responded_by ON responded_by.alert_id = alerts.id
                       LEFT JOIN users AS users_responded ON users_responded.id = responded_by.user_id
                       LEFT JOIN seen_by ON seen_by.alert_id = alerts.id
                       LEFT JOIN users AS users_seen ON users_seen.id = seen_by.user_id
                WHERE users_groups.group_id = $1
                 GROUP BY alerts.id, alerts_status.status, users.name, users.id, groups.name;`;

    return await pg
      .query(sql, [groupId])
      .then(result => {
        return result.rows;
      })
      .catch(err => err);
  }

  async getAllAlerts(user_id: number) {
    const sql = `SELECT  alerts.*,
                u.name as user_name,
                groups.name as group_name,
                u.id as created_by_user_id,
                   COALESCE(
                                JSON_AGG(
                                DISTINCT JSONB_BUILD_OBJECT(
                                        'name', users_responded.name,
                                        'response_time', responded_by.time
                                         )
                                        ) FILTER (WHERE users_responded.id IS NOT NULL), '[]'::JSON
                ) AS users_responded,
                COALESCE(
                                JSON_AGG(
                                DISTINCT JSONB_BUILD_OBJECT(
                                        'name', users_seen.name,
                                        'seen_time', seen_by.time
                                         )
                                        ) FILTER (WHERE users_seen.id IS NOT NULL), '[]'::JSON
                ) AS users_seen
              FROM alerts
                       JOIN alerts_type on alerts.type_id = alerts_type.id
                       JOIN alerts_status on alerts.status_id = alerts_status.id
                       JOIN devices ON alerts.triggering_device_id = devices.id
                       JOIN users_groups ON devices.user_id = users_groups.user_id
                       JOIN users as u on users_groups.user_id = u.id
                       JOIN ( SELECT * FROM users_groups WHERE user_id = $1) g_id ON g_id.group_id = users_groups.group_id
                       JOIN groups on g_id.group_id = groups.id
                       LEFT JOIN responded_by ON responded_by.alert_id = alerts.id
                       LEFT JOIN users AS users_responded ON users_responded.id = responded_by.user_id
                       LEFT JOIN seen_by ON seen_by.alert_id = alerts.id
                       LEFT JOIN users AS users_seen ON users_seen.id = seen_by.user_id
              GROUP BY alerts.id, alerts_status.status, u.name, u.id , groups.name;`;
    return await pg
      .query(sql, [user_id])
      .then(result => {
        return result.rows;
      })
      .catch(err => err);
  }
}
