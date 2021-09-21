using System;

namespace antra_
{
    /* Casing technique
     * 
     * Pascal casing: first letter of the words in an identifier must be Uppercase, others are lowercase. 
     * Use this to name a 1.class 2.method 3.Namespace 4.property 5.delegate 6.interface
     * 
     * Camel casing: identitdier
     * use this to name a: 1. variable 2. object
     * 
     * 
     */
    class Program
    {
        public void AddNumbers(int a, int b)
        {
            Console.WriteLine(a + b);
        }

        public int FindFactorial(int a)
        {
            int r = a;
            for (int i = a - 1; i > 0; i--)
            {
                r *= i;
            }

            return r;
        }



        public bool PrimeOrNot(int a)
        {
            bool r = true;
            for (int i = 2; i < a; i++)
            {
                if (a%i == 0)
                {
                    r = false;
                }
            }
            return r;
        }


        public bool LeapYear(int y)
        {
            if (y%4 == 0)
            {
                return true;
            }
            else
            {
                return false;
            }
        }


        public int LCM(int a, int b)
        {
            int num1, num2;
            if (a > b)
            {
                num1 = a; num2 = b;
            }
            else
            {
                num1 = b; num2 = a;
            }

            for (int i = 1; i < num2; i++)
            {
                int mult = num1 * i;
                if (mult % num2 == 0)
                {
                    return mult;
                }
            }
            //return num1 * num2;
        }


        static void Main(string[] args)
        {

            //float pi = 3.14f;
            //double gravity = 9.8;
            //string stringName = "SmithJ";

            //Console.WriteLine("Hello World!");

            int a = 20, b = 10;
            Program obj = new Program();
            obj.AddNumbers(2, 8);
            obj.AddNumbers(a, b);



            Console.WriteLine(obj.FindFactorial(3));
            Console.WriteLine(obj.PrimeOrNot(15));
            Console.WriteLine(obj.LeapYear(2021));
            Console.WriteLine(obj.LCM(3,4));
        }
    }
}
