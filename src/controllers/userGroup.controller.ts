import { NextFunction, Request, Response } from 'express';
import { Container } from 'typedi';
import { UserGroupService } from '@services/userGroup.service';
import { UserGroup } from '@interfaces/userGroup.interface';

export class UserGroupController {
  private userGroupService = Container.get(UserGroupService);

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

  public deleteUserGroup = (req: Request, res: Response, next: NextFunction) =>{
    try{
      const reqUserGroup: UserGroup = req.body;
      this.userGroupService.deleteUserGroup(reqUserGroup).then(result =>{
        if(result){
          res.status(200).json(result);
        }else{
          res.status(500).send('Could not delete users group');
        }
      })
    }catch(error){
      next(error);
    }
  }
}
