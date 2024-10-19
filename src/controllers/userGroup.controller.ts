import { NextFunction, Request, Response } from 'express';
import { Container } from 'typedi';
import { UserGroupService } from '@services/userGroup.service';
import { UserGroup, JoinUserGroup } from '@interfaces/userGroup.interface';

export class UserGroupController {
  private userGroupService = Container.get(UserGroupService);

  public getGroupsByUserId = async (req: Request, res: Response, next: NextFunction) => {
    try {
      // Extracting user id from URL parameters and convert userId to number
      const userId = Number(req.query.id);
      this.userGroupService.getGroupsByUserId(userId).then(result => {
        if (result) {
          res.status(200).json(result);
        } else {
          res.status(500).send('a group could not be created at this time');
        }
      });
    } catch (error) {
      next(error);
    }
  };

  public getAllUsersByGroupId = async (req: Request, res: Response, next: NextFunction) => {
    try {
      // Extracting user id from URL parameters and convert userId to number
      const groupId = Number(req.query.id);
      this.userGroupService.getAllUsersByGroupId(groupId).then(result => {
        if (result) {
          res.status(200).json(result);
        } else {
          res.status(500).send('a group could not be created at this time');
        }
      });
    } catch (error) {
      next(error);
    }
  };
  public createUserGroup = (req: Request, res: Response, next: NextFunction) => {
    try {
      const reqUserGroup: UserGroup = req.body;
      this.userGroupService.createUserGroup(reqUserGroup).then(result => {
        if (result) {
          res.status(200).json(result);
        } else {
          res.status(500).send('cannot create a group at this point');
        }
      });
    } catch (error) {
      next(error);
    }
  };

  public updateUserGroup = (req: Request, res: Response, next: NextFunction) => {
    const reqUserGroup = req.body;
    try {
      this.userGroupService.updateUserGroup(reqUserGroup).then(result => {
        if (result) {
          res.status(200).json(result);
        } else {
          res.status(500).send('Failed to update userGroup');
        }
      });
    } catch (err) {
      next(err);
    }
  };

  public deleteUserGroup = (req: Request, res: Response, next: NextFunction) => {
    try {
      const reqUserGroup: UserGroup = req.body;
      this.userGroupService.deleteUserGroup(reqUserGroup).then(result => {
        if (result) {
          res.status(200).json(result);
        } else {
          res.status(500).send('Could not delete users group');
        }
      });
    } catch (error) {
      next(error);
    }
  };

  JoinUserGroup(req: Request, res: Response, next: NextFunction) {
    try {
      console.log("")
      const joinUserGroup: JoinUserGroup = req.body;
      this.userGroupService.joinUserGroup(joinUserGroup).then(result => {
        if (result) {
          res.status(200).json(result);
        } else {
          res.status(500).send('Error creating user group');
        }
      });
    } catch (error) {
      next(error);
    }
  }
}
