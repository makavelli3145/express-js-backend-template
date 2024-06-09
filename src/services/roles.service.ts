import { Service } from 'typedi';
import pg from '@database';
import { HttpException } from '@exceptions/httpException';
import { logger } from '@utils/logger';

@Service()
export class RolesService {
  constructor() {}

  public async getRoleIDFromName(roleName: string): Promise<string | void> {
    return await pg
      .query(
        `
      SELECT id from roles WHERE role_name = $1
      `,
        [roleName],
      )
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0]?.id;
        } else {
          throw new HttpException(409, 'no role associated with the given role name');
        }
      })
      .catch(err => {
        throw new HttpException(500, 'database error');
      });
  }
}
