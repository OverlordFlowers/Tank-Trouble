// Depending on how precise we want the number to be, rounds to 0 if below tolerance.
// If floating point is below a certain number, clamp to 0.
static float tolerance(float num, float tolerance) {
  if (abs(num) < tolerance) {
    return 0f;
  }
  return num;
}

// Converting the angle to 2PI.
static float convertAngleTo2PI(float angle) {
  // Two cases: if above, or below. If above, the angle will be negative. If below, it is positive.
  if (angle <= 0) {
    return angle;
  } else {
    return (-2 * PI + angle);
  }
}
