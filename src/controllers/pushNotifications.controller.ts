import { NextFunction, Request, Response } from 'express';
import { Container } from 'typedi';
import { Group } from '@interfaces/group.interface';
import { PushNotification } from '@interfaces/pushNotification.interfact';
import { PushNotificationService } from '@services/pushNotification.service';
import { Device } from '@interfaces/device.interface';

export class PushNotificationsController {
  private pushNotificationService = Container.get(PushNotificationService);
  public createPushNotification(req: Request, res: Response, next: NextFunction) {
    try {
      const group: Group = req.body.group;
      const pushNotification: PushNotification = req.body.push_notifiaction;
      const device: Device = req.body.device;
      this.pushNotificationService.createPushNotification(group, pushNotification, device).then(result => {
        if (Array.isArray(result)) {
          this.pushNotificationService.createPushNotificationJob(result).then(result => {
            if (result) {
              res.status(200).send(result);
            } else {
              res.status(500).send('error creating push notification jobs');
            }
          });
        } else {
          res.status(500).send('could not create a push notification');
        }
      });
    } catch (error) {
      next(error);
    }
  }
}
