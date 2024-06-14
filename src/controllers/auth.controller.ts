import { Router } from 'express';
import { Container } from 'typedi';
import { Request, Response, NextFunction } from 'express';
import { RequestWithUser } from '@interfaces/auth.interface';
import { User } from '@interfaces/users.interface';
import { AuthService } from '@services/auth.service';
import { Device } from '@interfaces/device.interface';
import { uuid } from 'uuidv4';
import { DevicesService } from '@services/devices.service';
import { UserService } from '@services/users.service';
export class AuthController {
  public authService = Container.get(AuthService);
  public deviceService = Container.get(DevicesService);
  public userService = Container.get(UserService);

  public signUp = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const user: User = req.body;
      this.authService.idExists(user.id_number).then(userId => {
        if (userId) {
          if (typeof userId === 'number') {
            // Confirm if the the pin is correct before creating a device
            const isValidPinCode = this.authService.isValidPin(userId, user.pin);

            if (isValidPinCode) {
              const device: Device = {
                device_uuid: uuid(),
                user_id: userId,
              };
              this.deviceService.createDevice(device).then(createdDevice => res.status(200).json(createdDevice));
            } else {
              res.status(401).send('Your ID or password is wrong');
            }
          }
        } else {
          this.userService.createUser(user).then(createdUser => {
            if (typeof createdUser !== 'boolean' && 'id' in createdUser && createdUser?.id !== undefined) {
              const userId = createdUser.id;
              const device: Device = {
                device_uuid: uuid(),
                user_id: userId,
              };
              this.deviceService.createDevice(device).then(createdDevice => {
                if (typeof createdDevice !== 'boolean' && 'device_uuid' in createdDevice && createdDevice?.device_uuid !== undefined) {
                  res.status(200).json(createdDevice);
                } else {
                  res.status(401).send('device could not be registered');
                }
              });
            } else {
              res.status(401).send('user could not be registered');
            }
          });
        }
      });
    } catch (error) {
      next(error);
    }
  };

  public logIn = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
    } catch (error) {
      next(error);
    }
  };

  public logOut = async (req: RequestWithUser, res: Response, next: NextFunction): Promise<void> => {
    try {
    } catch (error) {
      next(error);
    }
  };
}
