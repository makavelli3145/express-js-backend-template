import { Router } from 'express';
import { Container } from 'typedi';
import { Request, Response, NextFunction } from 'express';
import { CreateDeviceDto } from '../dtos/device.dto';
import { Device } from '../interfaces/device.interface';
import { RequestWithUser } from '@interfaces/auth.interface';
import { User } from '@interfaces/users.interface';
import { AuthService } from '@services/auth.service';

const deviceRouter = Router();
const authController = Container.get(AuthService);

deviceRouter.post('/device', async (req: Request, res: Response, next: NextFunction) => {
  const createDeviceDto: CreateDeviceDto = req.body;

  const device: Device = {
    id: Math.floor(Math.random() * 1000),
    deviceKey: createDeviceDto.deviceKey,
  };

  res.status(201).json(device);
});

export class AuthController {
  public auth = Container.get(AuthService);

  public signUp = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userData: User = req.body;
      this.auth.idExists(userData.id_number).then(user_id => {
        if (user_id && typeof user_id === 'number') {
          this.auth.createDevice(user_id)
            .then(deviceId => res.status(200)
              .json({ deviceId: deviceId, message: "device added to user account" })
            );
        } else {
          this.auth.createUser(userData).then(user_id => {
            if (typeof user_id === 'number') {
              this.auth.createDevice(user_id)
                .then(deviceId => res.status(200)
                  .json({ deviceId: deviceId, message: "user created and device added to user account" })
                );
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
      const userData: User = req.body;
      const { cookie, findUser } = await this.auth.login(userData);

      res.setHeader('Set-Cookie', [cookie]);
      res.status(200).json({ data: findUser, message: 'login' });
    } catch (error) {
      next(error);
    }
  };

  public logOut = async (req: RequestWithUser, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userData: User = req.user;
      const logOutUserData: User = await this.auth.logout(userData);

      res.setHeader('Set-Cookie', ['Authorization=; Max-age=0']);
      res.status(200).json({ data: logOutUserData, message: 'logout' });
    } catch (error) {
      next(error);
    }
  };
}

export default deviceRouter;