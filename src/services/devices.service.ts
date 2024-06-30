import { Service } from 'typedi';
import pg from '@database';
import { Device } from '@interfaces/device.interface';

@Service()
export class DevicesService {
  async createDevice(device: Device): Promise<Device | boolean | NodeJS.ErrnoException> {
    const { device_uuid, user_id } = device;
    const sql = `INSERT into devices (device_uuid, user_id) VALUES ($1, $2) RETURNING id, device_uuid, user_id;`;
    return await pg
      .query(sql, [device_uuid, user_id])
      .then(result => {
        if (result.rowCount > 0) {
          return result.rows[0];
        } else {
          return false;
        }
      })
      .catch(err => err);
  }
  async deleteDevice(device: Device): Promise<Device | boolean | NodeJS.ErrnoException> {
    const { id } = device;
    const sql = `Delete FROM devices where id = $1;`;
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

  async findDeviceById(id: number) {
    const sql = `
      SELECT * FROM devices where id = $1;
    `;
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
