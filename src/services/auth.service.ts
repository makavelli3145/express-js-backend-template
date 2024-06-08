import { Service } from 'typedi';
import pg from '@database';
import { HttpException } from '@exceptions/httpException';
import { User } from '@interfaces/users.interface';
import { Device } from '@interfaces/device.interface';
import { uuid } from 'uuidv4';

@Service()
export class AuthService {
  async createUser(userData: User): Promise<number | boolean | NodeJS.ErrnoException> {
    try {
      const { idNumber, name, pinCode } = userData;
      const roleId = this.getUserRoleIdFromRoleName('user');
      if (typeof roleId === 'number') {
        return await pg
          .query(`INSERT INTO Users (id_number , role_id , pin , name) VALUES ($1, $2, $3, $4) RETURNING id`, [idNumber, roleId, pinCode, name])
          .then(result => {
            if (result.rowCount > 0) {
              return result.rows[0].id;
            } else {
              return false;
            }
          })
          .catch(err => err);
      } else {
        return false;
      }
    } catch (err) {
      return err;
    }
  }

  public async getUserRoleIdFromRoleName(roleName: string): Promise<number | boolean | NodeJS.ErrnoException> {
    return await pg
      .query('SELECT id FROM roles WHERE role_name = $1', [roleName])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0]?.id;
        } else {
          return false;
        }
      })
      .catch(err => err);
  }

  public async createDevice(userId: number): Promise<string | boolean | NodeJS.ErrnoException> {
    const deviceKey: string = uuid();
    return await pg
      .query(`INSERT INTO Devices ("device_uuid","user_id") VALUES ($1, $2) RETURNING id`, [deviceKey, userId])
      .then(result => {
        if (result.rowCount > 0) {
          return deviceKey;
        } else {
          return false;
        }
      })
      .catch(err => err);
  }

  async isValidPin(userId: number, userPin: string): Promise<boolean> {
    return await pg
      .query(
        `
      SELECT
        pin
      FROM
        users
      WHERE
        id = $1;
    `,
        [userId],
      )
      .then(result => {
        return userPin === result?.rows[0]?.pin;
      })
      .catch(err => err);
  }
  async idExists(id_number: string): Promise<boolean | number | NodeJS.ErrnoException> {
    return await pg
      .query(
        `
    SELECT EXISTS(
      SELECT
        "id"
      FROM
        users
      WHERE
        "id_number" = $1
    )`,
        [id_number],
      )
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0]?.id;
        } else {
          return false;
        }
      })
      .catch(err => err);
  }

  public async logout(userData: User): Promise<User> {
    const { idNumber, pinCode } = userData;

    const { rows, rowCount } = await pg.query(
      `
    SELECT
        "id_number",
        "pinCode"
      FROM
        users
      WHERE
        "id_number" = $1
      AND
        "pinCode" = $2
    `,
      [idNumber, pinCode],
    );
    if (!rowCount) throw new HttpException(409, "User doesn't exist");

    return rows[0];
  }
}
