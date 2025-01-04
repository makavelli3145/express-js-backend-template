import { Service } from 'typedi';
import pg from '@database';
import { Group } from '@interfaces/group.interface';

@Service()
export class GroupsService {
  public createGroup = async (group: Group): Promise<Group | boolean | NodeJS.ErrnoException> => {
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

  async getGroupsByUserId(userId: number) {
    const sql = `Select groups.id, groups.created_by_user_id, groups.name, groups.identification_string,  users_groups.roles_permissions_id
                   FROM users_groups
                   JOIN groups on users_groups.group_id=groups.id
                   WHERE user_id = $1;`;
    return await pg
      .query(sql, [userId])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows;
        } else {
          return false;
        }
      })
      .catch(err => err);
  }

  public updateGroup = async (group: Group): Promise<Group | boolean | NodeJS.ErrnoException> => {
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

  async deleteGroup(group: Group): Promise<Group | boolean | NodeJS.ErrnoException> {
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
