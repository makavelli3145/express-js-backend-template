import { Service } from 'typedi';
import pg from '@database';
import { Device } from '@interfaces/device.interface';

@Service()
export class DeviceService {
  public async findDeviceByKey(deviceKey: string): Promise<Device> {
    const { rows } = await pg.query(
      `SELECT * FROM devices WHERE "deviceKey" = $1`,
      [deviceKey],
    );

    return rows[0];
  }

  public async createDevice(deviceKey: string): Promise<Device> {
    const { rows } = await pg.query(
      `INSERT INTO devices ("deviceKey") VALUES ($1) RETURNING *`,
      [deviceKey],
    );

    return rows[0];
  }
}