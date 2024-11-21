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
  public getAlertByUserId = (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = Number(req.query.id);
      this.alertService.getAlertByUserId(userId).then(result => {
        if (result) {
          res.status(200).json(result);
        } else {
          res.status(500).send('server unable to get alerts by groupId');
        }
      });
    } catch (error) {
      next(error);
    }
  };

  const
  checkAlertParams = (params: any) => {
    const validParams = ["all", "userId", "groupId"];
    return validParams.includes(params);
  };
  public getAlertByUserAndGroupId = (req: Request, res: Response, next: NextFunction) => {

    const isValidParams = this.checkAlertParams(req.params.filterBy);
    console.log("isValidParams: ", isValidParams)

    if (isValidParams) {
      const urlParams = req.params.filterBy
      switch (urlParams) {
        default:
          res.status(500).send("There is an issue with getting alerts")

        case "userId":
          try {
            const userId = Number(req.params.userId);
            this.alertService.getAlertByUserId(userId).then(result => {
              if (result) {
                res.status(200).json(result);
              } else {
                res.status(500).send('server unable to get alerts by userId and groupId');
              }
            });
          }catch(error){
              next(error);
          }

        case "groupId":
          try {
            const groupId = Number(req.params.groupId);

            this.alertService.getAlertByGroupId(groupId).then(result => {
              if (result) {
                res.status(200).json(result);
              } else {
                res.status(500).send('server unable to get alerts by userId and groupId');
              }
            });
          } catch(error){
              next(error);
          }
        case "all":
          try {
            const userId = Number(req.params.userId);
            const groupId = Number(req.params.groupId);

            this.alertService.getAlertByUserAndGroupId(userId, groupId).then(result => {
              if (result) {
                res.status(200).json(result);
              } else {
                res.status(500).send('server unable to get alerts by userId and groupId');
              }
            });
          } catch(error){
              next(error);
          }
        }
      }else {
      res.status(500).send("Invalid url parameters")
    }
  }
}
