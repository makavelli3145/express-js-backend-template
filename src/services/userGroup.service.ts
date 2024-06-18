import { Service } from 'typedi';
import pg from '@database';
import { HttpException } from '@exceptions/httpException';
import { UserGroup } from '@interfaces/userGroup.interface';

@Service()
export class UserGroupService {
  public createUserGroup = async (reqUserGroup: UserGroup): Promise<UserGroup | boolean | NodeJS.ErrnoException> => {
    const { user_id, group_id, user_group_permissions } = reqUserGroup;
    const sql = `
      INSERT INTO users_groups (group_id, user_id, user_group_permissions) VALUES ( $1, $2, $3);
    `;
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
}
