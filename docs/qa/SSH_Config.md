
# Managing Multiple SSH Keys for QA Consultants

As QA consultants, managing SSH keys efficiently across projects is essential. Here are two approaches:

## Option 1: One SSH Key for Everything
### Steps:
1. **Generate an SSH Key:**
   ```
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```
2. **Add Key to Agent:**
   ```
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_rsa
   ```
3. **Add Key to Repository Platform:** Copy and paste the key into platform settings.

## Option 2: Multiple SSH Keys with Config
### Steps:
1. **Generate Multiple Keys:**
   ```
   ssh-keygen -t rsa -b 4096 -C "company1@example.com" -f ~/.ssh/id_rsa_company1
   ssh-keygen -t rsa -b 4096 -C "company2@example.com" -f ~/.ssh/id_rsa_company2
   ```
2. **Add Keys to Agent:**
   ```
   ssh-add ~/.ssh/id_rsa_company1
   ssh-add ~/.ssh/id_rsa_company2
   ```
3. **Create SSH Config File:**
   ```
   nano ~/.ssh/config
   ```
   Example Config:
   ```
   # Company 1
   Host company1
       HostName github.com
       User git
       IdentityFile ~/.ssh/id_rsa_company1

   # Company 2
   Host company2
       HostName gitlab.com
       User git
       IdentityFile ~/.ssh/id_rsa_company2
   ```

4. **Use the Config:** Clone using the defined Host:
   ```
   git clone git@company1:username/repo.git
   git clone git@company2:username/repo.git
   ```

## Which One to Use?
- Single Key: Simple, but less secure.
- Multiple Keys: Secure and clean for multiple clients.

The second method is recommended for better management.
