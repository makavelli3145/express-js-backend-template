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

  async getAllUsersByGroupId(groupId: number, user_id: number) {
    let sql = `SELECT  users_groups.roles_permissions_id FROM users_groups WHERE user_id = $1 and group_id = $2;`;
    return await pg
      .query(sql, [user_id, groupId])
      .then(async result => {
        if (result.rowCount > 0) {
          const permissions = result.rows[0].roles_permissions_id;
          switch (permissions) {
            case 2:
              sql = `SELECT users_groups.*, users.name
               FROM users_groups
               JOIN users ON users_groups.user_id = users.id
               WHERE users_groups.group_id = $1;`;
              return await pg
                .query(sql, [groupId])
                .then(result => {
                  if (result.rowCount > 0) {
                    return result.rows;
                  } else {
                    return [];
                  }
                })
                .catch(err => err);
            case 3:
              return [];
            case 4:
              sql = `SELECT users_groups.*, users.name
               FROM users_groups
               JOIN users ON users_groups.user_id = users.id
               WHERE users_groups.group_id = $1 and users_groups.roles_permissions_id  = 2 OR  users_groups.roles_permissions_id = 4;`;
              return await pg
                .query(sql, [groupId])
                .then(result => {
                  if (result.rowCount > 0) {
                    return result.rows;
                  } else {
                    return [];
                  }
                })
                .catch(err => err);
          }
        }
      })
      .catch(err => err);
  }

  public createUserGroup = async (reqUserGroup: UserGroup): Promise<UserGroup | boolean | NodeJS.ErrnoException> => {
    const { user_id, group_id, roles_permissions_id } = reqUserGroup;
    const sql = `
      INSERT INTO users_groups (group_id, user_id, roles_permissions_id) VALUES ( $1, $2, $3) RETURNING *;`;
    return await pg
      .query(sql, [group_id, user_id, roles_permissions_id])
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
    const { user_id, group_id, roles_permissions_id } = reqUserGroup;
    const sql: string = 'UPDATE users_groups SET user_id=$1, roles_permissions_id=$2 WHERE group_id=$3 RETURNING *';
    return await pg
      .query(sql, [user_id, roles_permissions_id, group_id])
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
    const { user_id, group_id, roles_permissions_id, id } = reqUserGroup;
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

  public joinUserGroup = async (joinUserGroup: JoinUserGroup) => {
    const { user_id, identification_string } = joinUserGroup;
    let sql = `SELECT id FROM groups WHERE identification_string = $1`;
    return await pg.query(sql, [identification_string]).then(async result => {
      if (result.rowCount > 0) {
        const id = result.rows[0].id;
        sql = `INSERT INTO users_groups (group_id, user_id, roles_permissions_id)
                    VALUES ($2, $1, 3 )
                  RETURNING *;`;
        const values = [user_id, id];
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
      } else {
        throw new Error('no groups associated with the identification string');
      }
    });
  };
}
