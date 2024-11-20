import { Service } from 'typedi';
import pg from '@database';
import { Group } from '@interfaces/group.interface';

@Service()
export class AlertService {
  public createAlert = async (alert: Alert): Promise<Group | boolean | NodeJS.ErrnoException> => {
    const { name, created_by_user_id, identification_string } = group;
    const sql = `INSERT INTO groups (name, created_by_user_id, identification_string) VALUES ( $1, $2, $3) RETURNING *`;
    return await pg
      .query(sql, [name, created_by_user_id, identification_string])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        } else {
          return false;
        }
      })
      .catch(error => error);
  };

  public updateAlert = async (group: Group): Promise<Group | boolean | NodeJS.ErrnoException> => {
    const { id, name, created_by_user_id } = group;
    const sql = `
      UPDATE groups SET name = $1, created_by_user_id = $2 WHERE id = $3 RETURNING *;`;
    return await pg
      .query(sql, [name, created_by_user_id, id])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        } else {
          return false;
        }
      })
      .catch(error => error);
  };

  async deleteAlert(group: Group): Promise<Group | boolean | NodeJS.ErrnoException> {
    const { id } = group;
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
