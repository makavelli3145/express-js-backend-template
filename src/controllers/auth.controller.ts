import { Router } from 'express';
import { Container } from 'typedi';
import { Request, Response, NextFunction } from 'express';
import { RequestWithUser } from '@interfaces/auth.interface';
import { User } from '@interfaces/users.interface';
import { AuthService } from '@services/auth.service';

export class AuthController {
  public authService = Container.get(AuthService);

  public signUp = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userData: User = req.body;
      this.authService.idExists(userData.idNumber).then(userId => {
        if (userId) {
          this.authService.createDevice(userId)
            .then(deviceId => res.status(200)
              .json({ deviceId: deviceId, message: "device added to user account" })
            );
        } else {
          this.authService.createUser(userData).then(userId => {
            if (typeof userId === 'number') {
              this.authService.createDevice(userId)
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

  public login = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      
    } catch (error) {
      next(error);
    }
  };

  public logOut = async (req: RequestWithUser, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userData: User = req.user;
      const logOutUserData: User = await this.authService.logout(userData);

      res.setHeader('Set-Cookie', ['Authorization=; Max-age=0']);
      res.status(200).json({ data: logOutUserData, message: 'logout' });
    } catch (error) {
      next(error);
    }
  };
}
