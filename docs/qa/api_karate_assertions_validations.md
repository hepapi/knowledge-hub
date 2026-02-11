# Assertions & Validations


Checking an HTTP status code is easy, but it doesn't give you much confidence. A real test needs to look deep into the JSON response. The problem is that real-world APIs are full of dynamic data—IDs, timestamps, and tokens that change every time you hit the endpoint. If you try to match these exactly, your tests will break constantly.

This is where **Fuzzy Matching** in Karate becomes a life-saver. Instead of asserting that an ID is 12345, you assert that it is *a number*.

#### **Key Matchers You’ll Actually Use**

Karate has a built-in vocabulary for handling dynamic data without the mess:

- **#notnull**: The field has to be there. Simple as that.
- **#number / #string / #boolean**: Checks the data type. Great for IDs or status flags.
- **#regex**: When you need a specific format (like an email or a UUID).
- **#ignore**: For those fields you just don't care about in a particular test.

You can combine these to validate a massive JSON object in a single line. It’s clean, and more importantly, it's stable.

### **Example Response Validation**

![Feature Example 2](https://hepapi.github.io/knowledge-hub/qa/karate1-media/media/image2.png)

In this example, we are validating the *shape* of the response. We don’t care if the userId is 1 or 100, as long as it’s a number. We don't care what the createdAt timestamp says, as long as it's a string.

#### **Why we use this approach**

Exact-value assertions are the number bir cause of "flaky tests." Nothing kills a team's trust in automation faster than a test that fails just because a timestamp changed by one second. Fuzzy matching allows you to focus on the **contract** of the API rather than the volatile data. It cuts down the noise and ensures that when a test fails, it’s because of a real bug, not a dynamic value.
