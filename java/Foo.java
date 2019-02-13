import java.util.List;

public class Foo {
    /*
      (Foo/multiply '(1 2 3 4))
      (Foo/multiply '())
      (Foo/multiply '(1 2 3 0 5))
    */
    public static Number multiply_(List<Long> numbers) {
        Long result = new Long(1);
        for (Long n : numbers) {
            result = result * n;
        }
        return result;
    }

    public static Number multiply(List<Long> numbers) {
        Long result = new Long(1);
        for (Long n : numbers) {
            if (n == 0) {
                // System.out.print("Break out of the loop and... ");
                // result = new Long(0);
                // break;

                System.out.println("Terminate computation immediatelly");
                return new Long(0);
            }
            result = result * n;
        }
        System.out.println("Terminate computation");
        return result;
    }

    /*
    (Foo/divide '(1 2 3 4))
    (Foo/divide '())
    (Foo/divide '(1 2 3 0 5))
    */
    // if the list of numbers contains 0 then...
    public static Number divide(List<Long> numbers) {
        Long result = new Long(1000 * 1000);
        for (Long n : numbers) {
            if (n == 0) {
                System.out.print("Division by 0 imminent... ");

                // System.out.println("And what?!? My name's Chuck Norris!");
                // n = new Long(1);

                System.out.println("Gonna be Ok :) Just look away for a moment.");
                continue;

                // System.out.println("Game over!");
                // System.exit(-1);
            }
            result = result / n;
        }
        return result;
    }
}
