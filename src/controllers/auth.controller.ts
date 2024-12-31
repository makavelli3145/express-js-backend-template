import { Container } from 'typedi';
import { Request, Response, NextFunction } from 'express';
import { RequestWithUser } from '@interfaces/auth.interface';
import { User } from '@interfaces/users.interface';
import { AuthService } from '@services/auth.service';
import { Device } from '@interfaces/device.interface';
import { v4 as uuid } from 'uuid';
import { DevicesService } from '@services/devices.service';
import { UserService } from '@services/users.service';
import * as console from 'console';
export class AuthController {
  public authService = Container.get(AuthService);
  public deviceService = Container.get(DevicesService);
  public userService = Container.get(UserService);

  public signUp = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const user: User = req.body;
      this.authService.idExists(user.id_number).then(userId => {
        if (userId) {
          if (req.body.mode === 'login') {
            if (typeof userId === 'number') {
              const isValidPinCode = this.authService.isValidPin(userId, user.pin);
              // If the user's ID number already exists, then:
              // 1) check if the pin is valid and then,
              // 2) create a new device that is is linked
              //    to the current user
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
            res.status(401).send('Account already exists please login instead');
          }
        } else {
          if (req.body.mode === 'register') {
            this.userService.createUser(user).then(createdUser => {
              console.log(createdUser);
              if (typeof createdUser !== 'boolean' && 'id' in createdUser && createdUser?.id !== undefined) {
                const userId = createdUser.id;
                const device: Device = {
                  device_uuid: uuid(),
                  user_id: userId,
                };
                this.deviceService.createDevice(device).then(createdDevice => {
                  console.log(createdDevice);
                  if (typeof createdDevice !== 'boolean' && 'device_uuid' in createdDevice && createdDevice?.device_uuid !== undefined) {
                    res.status(200).json({ device: createdDevice, user: createdUser });
                  } else {
                    res.status(401).send('device could not be registered');
                  }
                });
              } else {
                res.status(401).send('user could not be registered');
              }
            });
          } else {
            res.status(401).send('invalid login details');
          }
        }
      });
    } catch (error) {
      next(error);
    }
  };

  public logIn = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    const reqDevice: Device = req.body;
    try {
      this.deviceService.findDeviceById(reqDevice.id).then(device => {
        if (device) {
          const isValidDevice = device.device_uuid === reqDevice.device_uuid;
          if (isValidDevice) {
            const user_id = device.user_id;
            req.session.userId = user_id;
            this.userService.findUserById(user_id).then((user: User) => res.status(200).send(user));
          } else {
            res.status(401).send('There was a problem with logging in');
          }
        }
      });
    } catch (error) {
      next(error);
    }
  };

  public deregisterDevice = async (req: RequestWithUser, res: Response, next: NextFunction): Promise<void> => {
    const reqDevice: Device = req.body;
    try {
      this.deviceService.deleteDevice(reqDevice).then(device => {
        if (device) {
          res.status(200).send(device);
        } else {
          res.status(500).send('Device could not be deleted');
        }
      });
    } catch (error) {
      next(error);
    }
  };

  public deRegisterUser = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    const user: User = req.body;
    try {
      this.userService.deleteUser(user.id).then(result => {
        if (result) {
          res.status(200).send('user deleted');
        } else {
          res.status(401).send('user could not be deleted at this time');
        }
      });
    } catch (error) {
      next(error);
    }
  };

  public logout = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    req.session.destroy(err => {
      if (err) {
        return res.status(500).json({ error: 'Failed to logout' });
      }
      res.clearCookie('connect.sid'); // Clear the session cookie
      res.json({ message: 'Logged out successfully' });
    });
  };
}
