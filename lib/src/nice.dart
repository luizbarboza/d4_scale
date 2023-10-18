List<T> nicee<T extends Comparable>(
    List<T> domain, ({T Function(T) floor, T Function(T) ceil}) interval) {
  domain = domain.sublist(0);

  var i0 = 0, i1 = domain.length - 1, x0 = domain[i0], x1 = domain[i1];

  if (x1.compareTo(x0) < 0) {
    (i0, i1) = (i1, i0);
    (x0, x1) = (x1, x0);
  }

  domain[i0] = interval.floor(x0);
  domain[i1] = interval.ceil(x1);
  return domain;
}
