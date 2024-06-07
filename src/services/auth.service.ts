import { hash, compare } from 'bcrypt';
import { sign } from 'jsonwebtoken';
import { Service } from 'typedi';
import { SECRET_KEY } from '@config';
import pg from '@database';
import { HttpException } from '@exceptions/httpException';
import { DataStoredInToken, TokenData } from '@interfaces/auth.interface';
import { User } from '@interfaces/users.interface';

const createToken = (user: User): TokenData => {
  const dataStoredInToken: DataStoredInToken = { id: user.uuid};
  const expiresIn: number = 60 * 60;

  return { expiresIn, token: sign(dataStoredInToken, SECRET_KEY, { expiresIn }) };
};

const createCookie = (tokenData: TokenData): string => {
  return `Authorization=${tokenData.token}; HttpOnly; Max-Age=${tokenData.expiresIn};`;
};

@Service()
export class AuthService {
  createUser(userData: User): Promise<number | NodeJS.ErrnoException> {
    throw new Error('Method not implemented.');
  }
  async createDevice(user_id: number):Promise<string | NodeJS.ErrnoException> {
    throw new Error('Method not implemented.');
  }
  async idExists(id_number: string): Promise<boolean | number | NodeJS.ErrnoException> {
    throw new Error('Method not implemented.');
  }
  public async signup(userData: User): Promise<User> {
    const { id_number, pinCode } = userData;

    const { rows: findUser } = await pg.query(
      `
    SELECT EXISTS(
      SELECT
        "id_number"
      FROM
        users
      WHERE
        "id_number" = $1
    )`,
      [id_number],
    );
    if (findUser[0].exists) throw new HttpException(409, `This id_number ${userData.id_number} already exists`);

    const hashedpinCode = await hash(pinCode, 10);
    const { rows: signUpUserData } = await pg.query(
      `
      INSERT INTO
        users(
          "id_number",
          "pinCode"
        )
      VALUES ($1, $2)
      RETURNING "id_number", "pinCode"
      `,
      [id_number, hashedpinCode],
    );

    return signUpUserData[0];
  }

  public async login(userData: User): Promise<{ cookie: string; findUser: User }> {
    const { id_number, pinCode } = userData;

    const { rows, rowCount } = await pg.query(
      `
      SELECT
        "id_number",
        "pinCode"
      FROM
        users
      WHERE
        "id_number" = $1
    `,
      [id_number],
    );
    if (!rowCount) throw new HttpException(409, `This id_number ${id_number} was not found`);

    const ispinCodeMatching: boolean = await compare(pinCode, rows[0].pinCode);
    if (!ispinCodeMatching) throw new HttpException(409, "You're pinCode not matching");

    const tokenData = createToken(rows[0]);
    const cookie = createCookie(tokenData);
    return { cookie, findUser: rows[0] };
  }

  public async logout(userData: User): Promise<User> {
    const { id_number, pinCode } = userData;

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
      [id_number, pinCode],
    );
    if (!rowCount) throw new HttpException(409, "User doesn't exist");

    return rows[0];
  }
}
