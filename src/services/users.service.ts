import { Service } from 'typedi';
import pg from '@database';
import { User } from '@interfaces/users.interface';

@Service()
export class UserService {
  public async findAllUser(): Promise<User[] | boolean | NodeJS.ErrnoException> {
    return await pg
      .query(
        `
    SELECT
      *
    FROM
      users
    `,
      )
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows;
        }
        return false;
      })
      .catch(error => {
        return error;
      });
  }

  public async findUserById(userId: number): Promise<User> {
    return await pg
      .query(
        `
    SELECT
      *
    FROM
      users
    WHERE
      id = $1
    `,
        [userId],
      )
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        }
        return false;
      })
      .catch(error => {
        return error;
      });
  }

  public async createUser(userData: User): Promise<User | boolean | NodeJS.ErrnoException> {
    const { id_number, pin, name } = userData;

    const sql: string = `INSERT INTO
            users (id_number, role_id, pin, name)
            VALUES
                ($1, $2, $3, $4) RETURNING id, id_number, role_id, name`;

    return await pg
      .query(sql, [id_number, 1, pin, name])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        }
        return false;
      })
      .catch(error => {
        return error;
      });
  }

  public async updateUser(user: User, id: number): Promise<User | boolean | NodeJS.ErrnoException> {
    const { email, phone_number, address, emergency_contact_number, emergency_contact_name} = user;
    const sql = `UPDATE users SET email = $1, phone_number = $2, address = $3, emergency_contact_name=$4, emergency_contact_number=$5 where id = $6 RETURNING *`;
    return await pg
      .query(sql, [email, phone_number, address,emergency_contact_name, emergency_contact_number, id])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        }
        return false;
      })
      .catch(error => {
        return error;
      });
  }

  public async deleteUser(userId: number): Promise<User | boolean | NodeJS.ErrnoException> {
    const sql = `DELETE FROM users WHERE id = $1 RETURNING *;`;
    return await pg
      .query(sql, [userId])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        }
        return false;
      })
      .catch(error => {
        return error;
      });
  }
}
