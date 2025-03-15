let a = 12;
let b = 7;
let sum = a + b;
let prod = a * b;

console.log("The sum of a and b is:");
console.log(sum);
wait(0.5);

console.log("The product of a and b is:");
console.log(prod);
wait(0.5);

if (a > b) {
    console.log("a is greater than b");
    let diff = a - b;
    console.log("The difference (a - b) is:");
    console.log(diff);
    wait(1);
}

console.log("BashJS");
