from easy_trilateration.model import *  
from easy_trilateration.least_squares import easy_least_squares  
from easy_trilateration.graph import *  


def trilateration(positions):
    circle, meta = easy_least_squares(positions)
    return circle.center.x, circle.center.y



""" if __name__ == '__main__':  
    arr = [Circle(2, 2, 1.176),  
  Circle(1.13398, 0.5, 0.925),  
  Circle(2.86603, 0.5, 1.231)] 
    result, meta = easy_least_squares(arr)  
    create_circle(result, target=True)  
    #print(result)
    #print(meta)
    trilateration(arr) """

