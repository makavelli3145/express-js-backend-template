import { NextFunction, Request, Response } from 'express';
import { Container } from 'typedi';
import { Alert } from '@interfaces/alert.interface';
import { AlertService } from '@services/alert.service';

export class AlertController {
  public alertService = Container.get(AlertService);
  public createAlert = (req: Request, res: Response, next: NextFunction) => {
    try {
      const alert: Alert = req.body;
      this.alertService.createAlert(alert).then(result => {
        if (result) {
          res.status(200).json(result);
        } else {
          res.status(500).send('an alert could not be created at this time');
        }
      });
    } catch (error) {
      next(error);
    }
  };

  public deleteAlert = (req: Request, res: Response, next: NextFunction) => {
    try {
      const alert: Alert = req.body;
      this.alertService.deleteAlert(alert).then(result => {
        if (result) {
          res.status(200).json(result);
        } else {
          res.status(500).send('There was an error with deleting an alert');
        }
      });
    } catch (error) {
      next(error);
    }
  };

  public updateAlert = (req: Request, res: Response, next: NextFunction) => {
    try {
      const alert: Alert = req.body;
      this.alertService.updateAlert(alert).then(result => {
        if (result) {
          res.status(200).json(result);
        } else {
          res.status(500).send('an alert could not be updated at this time');
        }
      });
    } catch (error) {
      next(error);
    }
  };
}
