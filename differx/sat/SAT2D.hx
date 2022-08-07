package differx.sat;

import differx.math.*;
import differx.shapes.*;
import differx.data.*;
import differx.math.Util.*;
import hvector.*;

/** Implementation details for the 2D SAT collision queries.
	Used by the various shapes, and Collision API, mostly internally. */
class SAT2D {
	/** Internal api - test a circle against a polygon */
	public static function testCircleVsPolygon(circle:Circle, polygon:Polygon, ?into:ShapeCollision, flip:Bool = false):ShapeCollision {
		into = into == null ? new ShapeCollision() : into.reset();

		var verts = polygon.vertices;

		var circleX = circle.center.x;
		var circleY = circle.center.y;

		var testDistance:Float = 0x3FFFFFFF;
		var distance = 0.0, closestX = 0.0, closestY = 0.0;

		for (i in 0...verts.length) {
			var v = verts[i];

			distance = vec_lengthsq(circleX - v.x, circleY - v.y);

			if (distance < testDistance) {
				testDistance = distance;
				closestX = v.x;
				closestY = v.y;
			}
		} // for

		var normalAxisX = closestX - circleX;
		var normalAxisY = closestY - circleY;
		var normAxisLen = vec_length(normalAxisX, normalAxisY);
		normalAxisX = vec_normalize(normAxisLen, normalAxisX);
		normalAxisY = vec_normalize(normAxisLen, normalAxisY);

		// project all its points, 0 outside the loop
		var test = 0.0;
		var v0 = verts[0];
		var min1 = vec_dot(normalAxisX, normalAxisY, v0.x, v0.y);
		var max1 = min1;

		for (j in 1...verts.length) {
			var v = verts[j];
			test = vec_dot(normalAxisX, normalAxisY, v.x, v.y);
			if (test < min1)
				min1 = test;
			if (test > max1)
				max1 = test;
		} // each vert

		// project the circle
		var max2 = circle.radius;
		var min2 = -circle.radius;
		var offset = vec_dot(normalAxisX, normalAxisY, -circleX, -circleY);

		min1 += offset;
		max1 += offset;

		var test1 = min1 - max2;
		var test2 = min2 - max1;

		// if either test is greater than 0, there is a gap, we can give up now.
		if (test1 > 0 || test2 > 0)
			return null;

		// circle distance check
		var distMin = -(max2 - min1);
		if (flip)
			distMin *= -1;

		into.overlap = distMin;
		into.unitVectorX = normalAxisX;
		into.unitVectorY = normalAxisY;
		var closest = Math.abs(distMin);

		// find the normal axis for each point and project
		for (i in 0...verts.length) {
			normalAxisX = findNormalAxisX(verts, i);
			normalAxisY = findNormalAxisY(verts, i);
			var aLen = vec_length(normalAxisX, normalAxisY);
			normalAxisX = vec_normalize(aLen, normalAxisX);
			normalAxisY = vec_normalize(aLen, normalAxisY);

			// project the polygon(again? yes, circles vs. polygon require more testing...)
			min1 = vec_dot(normalAxisX, normalAxisY, verts[0].x, verts[0].y);
			max1 = min1; // set max and min

			// project all the other points(see, cirlces v. polygons use lots of this...)
			for (j in 1...verts.length) {
				test = vec_dot(normalAxisX, normalAxisY, verts[j].x, verts[j].y);
				if (test < min1)
					min1 = test;
				if (test > max1)
					max1 = test;
			}

			// project the circle(again)
			max2 = circle.radius; // max is radius
			min2 = -circle.radius; // min is negative radius

			// offset points
			offset = vec_dot(normalAxisX, normalAxisY, -circleX, -circleY);
			min1 += offset;
			max1 += offset;

			// do the test, again
			test1 = min1 - max2;
			test2 = min2 - max1;

			// failed.. quit now
			if (test1 > 0 || test2 > 0) {
				return null;
			}

			distMin = -(max2 - min1);
			if (flip)
				distMin *= -1;

			if (Math.abs(distMin) < closest) {
				into.unitVectorX = normalAxisX;
				into.unitVectorY = normalAxisY;
				into.overlap = distMin;
				closest = Math.abs(distMin);
			}
		} // for

		// if you made it here, there is a collision!!!!!

		into.shape1 = if (flip) polygon.original else circle.original;
		into.shape2 = if (flip) circle.original else polygon.original;
		into.separationX = into.unitVectorX * into.overlap;
		into.separationY = into.unitVectorY * into.overlap;

		if (!flip) {
			into.unitVectorX = -into.unitVectorX;
			into.unitVectorY = -into.unitVectorY;
		}

		return into;
	} // testCircleVsPolygon

	/** Internal api - test a circle against a circle */
	public static function testCircleVsCircle(circleA:Circle, circleB:Circle, ?into:ShapeCollision, flip:Bool = false):ShapeCollision {
		//

		var circle1 = flip ? circleB : circleA;
		var circle2 = flip ? circleA : circleB;

		var center1 = flip ? circleB.center : circleA.center;
		var center2 = flip ? circleA.center : circleB.center;

		// add both radii together to get the colliding distance
		var totalRadius = circle1.radius + circle2.radius;
		// find the distance between the two circles using Pythagorean theorem. No square roots for optimization
		var distancesq = vec_lengthsq(center1.x - center2.x, center1.y - center2.y);

		// if your distance is less than the totalRadius square(because distance is squared)
		if (distancesq < totalRadius * totalRadius) {
			into = (into == null) ? new ShapeCollision() : into.reset();
			// find the difference. Square roots are needed here.
			var difference = totalRadius - Math.sqrt(distancesq);

			into.shape1 = circle1.original;
			into.shape2 = circle2.original;

			var unitVecX = center1.x - center2.x;
			var unitVecY = center1.y - center2.y;
			var unitVecLen = vec_length(unitVecX, unitVecY);

			unitVecX = vec_normalize(unitVecLen, unitVecX);
			unitVecY = vec_normalize(unitVecLen, unitVecY);

			into.unitVectorX = unitVecX;
			into.unitVectorY = unitVecY;

			// find the movement needed to separate the circles
			into.separationX = into.unitVectorX * difference;
			into.separationY = into.unitVectorY * difference;
			into.overlap = difference;

			return into;
		} // if distancesq < r^2

		return null;
	} // testCircleVsCircle

	/** Internal api - test a polygon against another polygon */

	// THIS IS A HUGE FLAW - Makes testing polygons not thread safe!!!
//	static var tmp1:ShapeCollision = new ShapeCollision();
//	static var tmp2:ShapeCollision = new ShapeCollision();

	public static function testPolygonVsPolygon(polygon1:Polygon, polygon2:Polygon, temp:ShapeCollision, ?into:ShapeCollision, flip:Bool = false):ShapeCollision {
		into = (into == null) ? new ShapeCollision() : into.reset();

		temp.reset();

		if (checkPolygons(polygon1, polygon2, into, flip) == null) {
			return null;
		}

		if (checkPolygons(polygon2, polygon1, temp, !flip) == null) {
			return null;
		}

		var result = null, other = null;
		if (Math.abs(into.overlap) < Math.abs(temp.overlap)) {
			result = into;
			other = temp;
		} else {
			result = temp;
			other = into;
		}

		result.otherOverlap = other.overlap;
		result.otherSeparationX = other.separationX;
		result.otherSeparationY = other.separationY;
		result.otherunitVectorX = other.unitVectorX;
		result.otherunitVectorY = other.unitVectorY;

		if (into != result) {
			into.copy_from(result);
		}

		//Why?
		result = other = null;

		return into;
	} // testPolygonVsPolygon

	static inline function valid_t(ray:Ray, t:Float) {
		return if (ray.flags & Ray.TraceFlags.INFINITE == 0) {
			if (ray.flags & Ray.TraceFlags.BIDIRECTIONAL == 0) t >= 0.0 && t <= 1.0; else t >= -1.0 && t <= 1.0;
		} else {
			if (ray.flags & Ray.TraceFlags.BIDIRECTIONAL == 0) t != Math.POSITIVE_INFINITY && t >= 0.0;
			else
				true;
		}
	}

	/** Internal api - test a ray against a circle */
	public static function testRayVsCircle(ray:Ray, circle:Circle, ?into:RayCollision):RayCollision {
		var deltaX = ray.end.x - ray.origin.x;
		var deltaY = ray.end.y - ray.origin.y;
		var ray2circleX = ray.origin.x - circle.center_x;
		var ray2circleY = ray.origin.y - circle.center_y;

		var a = vec_lengthsq(deltaX, deltaY);
		var b = 2 * vec_dot(deltaX, deltaY, ray2circleX, ray2circleY);
		var c = vec_dot(ray2circleX, ray2circleY, ray2circleX, ray2circleY) - (circle.radius * circle.radius);
		var d = b * b - 4 * a * c;

		if (d >= 0) {
			d = Math.sqrt(d);

			var t1 = (-b - d) / (2 * a);
			var t2 = (-b + d) / (2 * a);

			var valid = valid_t(ray, t1);

			if (valid) {
				into = (into == null) ? new RayCollision() : into.reset();

				into.shape = circle;
				into.ray = ray;
				into.start = t1;
				into.end = t2;

				if (ray.flags & Ray.TraceFlags.CONTACT_INFO != 0) {
					into.point = ray.getPoint(t1);
					into.normal = (into.point - circle.center).normalized();
				}
				return into;
			} //
		} // d >= 0

		return null;
	} // testRayVsCircle

	/** Internal api - test a ray against a polygon */
	public static function testRayVsPolygon(ray:Ray, polygon:Polygon, ?into:RayCollision):RayCollision {
		var min_u = Math.POSITIVE_INFINITY;
		var max_u = Math.NEGATIVE_INFINITY;

		var min_edge = -1;

		var startX = ray.origin.x;
		var startY = ray.origin.y;
		var deltaX = ray.end.x - startX;
		var deltaY = ray.end.y - startY;

		var verts = polygon.vertices;
		var v1 = verts[verts.length - 1];
		var v2 = verts[0];

		{
			final ud = (v2.y - v1.y) * deltaX - (v2.x - v1.x) * deltaY;

			if (ud != 0.0) {
				final ub = rayU(ud, startX, startY, v1.x, v1.y, deltaX, deltaY);
				if (ub >= 0.0 && ub <= 1.0) {
					final ua = rayU(ud, startX, startY, v1.x, v1.y, v2.x - v1.x, v2.y - v1.y);
					if (ua < min_u) {
						min_u = ua;
						min_edge = 0;
					}
					if (ua > max_u)
						max_u = ua;
				}
			}
		}
		for (i in 1...verts.length) {
			v1 = verts[i - 1];
			v2 = verts[i];

			final ud = (v2.y - v1.y) * deltaX - (v2.x - v1.x) * deltaY;

			if (ud != 0.0) {
				final ub = rayU(ud, startX, startY, v1.x, v1.y, deltaX, deltaY);
				if (ub >= 0.0 && ub <= 1.0) {
					final ua = rayU(ud, startX, startY, v1.x, v1.y, v2.x - v1.x, v2.y - v1.y);
					if (ua < min_u) {
						min_u = ua;
						min_edge = i;
					}
					if (ua > max_u)
						max_u = ua;
				}
			}
		} // each vert

		var valid =  min_edge > -1 && valid_t(ray, min_u);

		if (valid) {
			into = (into == null) ? new RayCollision() : into.reset();
			into.shape = polygon;
			into.ray = ray;
			into.start = min_u;
			into.end = max_u;

			if (ray.flags & Ray.TraceFlags.CONTACT_INFO != 0) {
				into.point = ray.getPoint(min_u);

				v1 = verts[(min_edge - 1 + verts.length) % verts.length];
				v2 = verts[min_edge];
				var e = (v2 - v1).normalized();
				into.normal = new Float2( e.y, e.x ); // Could be inverted, need to understand winding. Assumes CCW winding
			}

			return into;
		}

		return null;
	} // testRayVsPolygon

	/** Internal api - test a ray against another ray */
	public static function testRayVsRay(ray1:Ray, ray2:Ray, ?into:RayIntersection):RayIntersection {
		var delta1X = ray1.end.x - ray1.origin.x;
		var delta1Y = ray1.end.y - ray1.origin.y;
		var delta2X = ray2.end.x - ray2.origin.x;
		var delta2Y = ray2.end.y - ray2.origin.y;
		var diffX = ray1.origin.x - ray2.origin.x;
		var diffY = ray1.origin.y - ray2.origin.y;
		var ud = delta2Y * delta1X - delta2X * delta1Y;

		if (ud == 0.0)
			return null;

		var u1 = (delta2X * diffY - delta2Y * diffX) / ud;
		var u2 = (delta1X * diffY - delta1Y * diffX) / ud;

		// :todo: ask if ray hit condition difference is intentional (> 0 and not >= 0 like other checks)
		// [RC] ask whom exactly?
		var valid1 = valid_t(ray1, u1);
		var valid2 = valid_t(ray2, u2);

		if (valid1 && valid2) {
			into = (into == null) ? new RayIntersection() : into.reset();

			into.ray1 = ray1;
			into.ray2 = ray2;
			into.u1 = u1;
			into.u2 = u2;

			return into;
		} // both valid

		return null;
	} // testRayVsRay

	// Internal implementation detail helpers

	/** Internal api - implementation details for testPolygonVsPolygon */
	static function checkPolygons(polygon1:Polygon, polygon2:Polygon, into:ShapeCollision, flip:Bool = false):ShapeCollision {
		into.reset();

		var offset = 0.0, test1 = 0.0, test2 = 0.0, testNum = 0.0;
		var min1 = 0.0, max1 = 0.0, min2 = 0.0, max2 = 0.0;
		var closest:Float = 0x3FFFFFFF;

		var axisX = 0.0;
		var axisY = 0.0;
		var verts1 = polygon1.vertices;
		var verts2 = polygon2.vertices;

		// loop to begin projection
		for (i in 0...verts1.length) {
			axisX = findNormalAxisX(verts1, i);
			axisY = findNormalAxisY(verts1, i);
			var aLen = vec_length(axisX, axisY);
			axisX = vec_normalize(aLen, axisX);
			axisY = vec_normalize(aLen, axisY);

			// project polygon1
			min1 = vec_dot(axisX, axisY, verts1[0].x, verts1[0].y);
			max1 = min1;

			for (j in 1...verts1.length) {
				testNum = vec_dot(axisX, axisY, verts1[j].x, verts1[j].y);
				if (testNum < min1)
					min1 = testNum;
				if (testNum > max1)
					max1 = testNum;
			}

			// project polygon2
			min2 = vec_dot(axisX, axisY, verts2[0].x, verts2[0].y);
			max2 = min2;

			for (j in 1...verts2.length) {
				testNum = vec_dot(axisX, axisY, verts2[j].x, verts2[j].y);
				if (testNum < min2)
					min2 = testNum;
				if (testNum > max2)
					max2 = testNum;
			}

			test1 = min1 - max2;
			test2 = min2 - max1;

			if (test1 > 0 || test2 > 0)
				return null;

			var distMin = -(max2 - min1);
			if (flip)
				distMin *= -1;

			if (Math.abs(distMin) < closest) {
				into.unitVectorX = axisX;
				into.unitVectorY = axisY;
				into.overlap = distMin;
				closest = Math.abs(distMin);
			}
		}

		into.shape1 = if (flip) polygon2.original else polygon1.original;
		into.shape2 = if (flip) polygon1.original else polygon2.original;
		into.separationX = -into.unitVectorX * into.overlap;
		into.separationY = -into.unitVectorY * into.overlap;

		if (flip) {
			into.unitVectorX = -into.unitVectorX;
			into.unitVectorY = -into.unitVectorY;
		}

		return into;
	} // checkPolygons

	// Internal helpers

	/** Internal helper for ray overlaps */
	static inline function rayU(udelta:Float, aX:Float, aY:Float, bX:Float, bY:Float, dX:Float, dY:Float):Float {
		return (dX * (aY - bY) - dY * (aX - bX)) / udelta;
	} // rayU

	static inline function findNormalAxisX(verts:Float2Array, index:Int):Float {
		var v2 = (index >= verts.length - 1) ? verts[0] : verts[index + 1];
		return -(v2.y - verts[index].y);
	}

	static inline function findNormalAxisY(verts:Float2Array, index:Int):Float {
		var v2 = (index >= verts.length - 1) ? verts[0] : verts[index + 1];
		return (v2.x - verts[index].x);
	}
} // SAT2D
