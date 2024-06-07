import { Request, Response, NextFunction } from 'express';
import { Service } from 'typedi';
import { DeviceService } from '@services/device.service';
import { CreateDeviceDto } from '@dtos/device.dto';
import { HttpException } from '@exceptions/httpException';

@Service()
export class DeviceController {
  constructor(private readonly deviceService: DeviceService) {}

  public createDevice = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    const deviceData: CreateDeviceDto = req.body;

    try {
      const existingDevice = await this.deviceService.findDeviceByKey(deviceData.deviceKey);
      if (existingDevice) {
        throw new HttpException(409, `Device with key ${deviceData.deviceKey} already exists`);
      }

      const newDevice = await this.deviceService.createDevice(deviceData.deviceKey);
      res.status(201).json({ data: newDevice, message: 'Device created' });
    } catch (error) {
      next(error);
    }
  };
}