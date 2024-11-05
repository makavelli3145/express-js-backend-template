import { Service } from 'typedi';
import pg from '@database';
import { HttpException } from '@exceptions/httpException';
import { JoinUserGroup, UserGroup } from '@interfaces/userGroup.interface';

@Service()
export class UserGroupService {

  async getUserGroupsByGroupId(groupId: number, user_id: number) {
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

  async getUserGroupsByUserId(user_id: number) {
    const sql = `SELECT * from users_groups
     WHERE user_id = $1;`;
    return await pg
      .query(sql, [user_id])
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

  private findAdditionalAdmins = async (groupId: number): Promise<boolean | NodeJS.ErrnoException> => {
    const sql = 'SELECT user_id FROM users_groups WHERE group_id = $1 AND roles_permissions_id = 2;';
    return await pg
      .query(sql, [groupId])
      .then(result => {
        return result.rows.length > 1;
      })
      .catch(err => {
        return err;
      });
  }

  public deleteUserGroup = async (reqUserGroup: UserGroup): Promise<UserGroup | boolean | NodeJS.ErrnoException> => {
    const { user_id, group_id, roles_permissions_id, id } = reqUserGroup;

    const isAdditionalAdmin = await this.findAdditionalAdmins(group_id); // Pass groupId here

    if (roles_permissions_id === 2 && !isAdditionalAdmin) {
      try {
        // First, delete the user group entry
        const deleteResult = await pg.query('DELETE FROM users_groups WHERE id = $1 RETURNING *', [id]);
        if (deleteResult.rowCount === 0) return false;

        // Next, update the roles_permissions_id for the user with the minimum user_id in the group
        await pg.query(`
        UPDATE users_groups
        SET roles_permissions_id = 2
        WHERE user_id = (
          SELECT MIN(user_id) FROM users_groups WHERE group_id = $1
        )`, [group_id]);

        return deleteResult.rows[0]; // Return the deleted row data
      } catch (err) {
        return err;
      }
    } else {
      // Just delete the user group entry without the additional update
      return await pg
        .query('DELETE FROM users_groups WHERE id = $1 RETURNING *', [id])
        .then(result => (result.rowCount > 0 ? result.rows[0] : false))
        .catch(err => err);
    }
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
