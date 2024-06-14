import { Service } from 'typedi';
import pg from '@database';

@Service()
export class AuthService {
  async isValidPin(userId: number, userPin: string): Promise<boolean> {
    const sql = `SELECT pin FROM users WHERE id = $1`;
    return await pg
      .query(sql, [userId])
      .then(result => {
        if (result.rowCount > 0) {
          return userPin === result?.rows[0]?.pin;
        } else {
          false;
        }
      })
      .catch(err => err);
  }
  async idExists(id_number: string): Promise<boolean | number | NodeJS.ErrnoException> {
    const sql = `
      SELECT id FROM users WHERE id_number = $1`;
    return await pg
      .query(sql, [id_number])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0]?.id;
        } else {
          return false;
        }
      })
      .catch(err => err);
  }
}
