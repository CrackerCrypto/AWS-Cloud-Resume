window.addEventListener("DOMContentLoaded", (event) => {
  updateCounter();
});

const counter = document.querySelector("#counter");
const updateCounter = async () => {
  let response = await fetch(
    "https://ln2sa2gdyjj4j4wokc4xuotguy0hydbr.lambda-url.ap-south-1.on.aws/"
  );
  let data = await response.json();
  counter.innerText = `${data}`;
};
