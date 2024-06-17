import { Service } from 'typedi';
import pg from '@database';
import { Group } from '@interfaces/group.interface';
import {Device} from "@interfaces/device.interface";

@Service()
export class GroupsService {
  public createGroup = async (group: Group): Promise<Group | boolean | NodeJS.ErrnoException> => {
    const { name, created_by_user_id } = group;
    const sql = `INSERT INTO groups (name, created_by_user_id) VALUES ( $1, $2)`;
    return await pg
      .query(sql, [name, created_by_user_id])
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
      const sql = `Delete FROM groups where id = $1;`
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
