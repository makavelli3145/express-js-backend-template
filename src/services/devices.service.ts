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
    const selectSql = 'Select id, device_uuid, user_id from devices where id = $1';
    const deleteSql = `Delete FROM devices where id = $1;`

    let deviceDetails;

    await pg
      .query(selectSql, [id])
      .then(result =>{
        if(result.rowCount > 0){
          deviceDetails = result.rows[0];
        }else{
          return false;
        }
      }).catch(err => err);

    return await pg
      .query(deleteSql, [id])
      .then(result => {
        if (result.rowCount > 0) {
          return deviceDetails;
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
