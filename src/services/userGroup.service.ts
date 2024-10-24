import { Service } from 'typedi';
import pg from '@database';
import { HttpException } from '@exceptions/httpException';
import { JoinUserGroup, UserGroup } from '@interfaces/userGroup.interface';

@Service()
export class UserGroupService {
  async getGroupsByUserId(userId: number) {
    const sql = `Select groups.id, groups.created_by_user_id, groups.name,  users_groups.roles_permissions_id
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

  async getAllUsersByGroupId(groupId: number) {
    const sql = 'Select * FROM users_groups WHERE group_id = $1;';
    return await pg
      .query(sql, [groupId])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows;
        } else {
          return false;
        }
      })
      .catch(err => err);
  }
  public createUserGroup = async (reqUserGroup: UserGroup): Promise<UserGroup | boolean | NodeJS.ErrnoException> => {
    const { user_id, group_id, user_group_permissions } = reqUserGroup;
    const sql = `
      INSERT INTO users_groups (group_id, user_id, user_group_permissions) VALUES ( $1, $2, $3) RETURNING *;`;
    return await pg
      .query(sql, [group_id, user_id, user_group_permissions])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        } else {
          return false;
        }
      })
      .catch(error => error);
  };

  public updateUserGroup = async (reqUserGroup: UserGroup): Promise<UserGroup | boolean | NodeJS.ErrnoException> => {
    const { user_id, group_id, user_group_permissions } = reqUserGroup;
    const sql: string = 'UPDATE users_groups SET user_id=$1, user_group_permissions=$2 WHERE group_id=$3 RETURNING *';
    return await pg
      .query(sql, [user_id, user_group_permissions, group_id])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        } else {
          return false;
        }
      })
      .catch(err => err);
  };

  public deleteUserGroup = async (reqUserGroup: UserGroup): Promise<UserGroup | boolean | NodeJS.ErrnoException> => {
    const { user_id, group_id, user_group_permissions, id } = reqUserGroup;
    const sql: string = 'DELETE FROM users_groups WHERE id=$1 RETURNING *';
    return await pg
      .query(sql, [id])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        } else {
          return false;
        }
      })
      .catch(err => {
        return err;
      });
  };

  public async joinUserGroup(joinUserGroup: JoinUserGroup): Promise<UserGroup | boolean | NodeJS.ErrnoException> {
    const { user_id, identification_string } = joinUserGroup;
    const sql = `INSERT INTO users_groups (group_id, user_id, roles_permissions_id)
                 VALUES ((SELECT id FROM groups WHERE identification_string = $1), $2, 3)
                   RETURNING *;`;
    const values = [identification_string, user_id];
    return await pg
      .query(sql, values)
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        } else {
          return false;
        }
      })
      .catch(err => {
        return err;
      });
  }
}
