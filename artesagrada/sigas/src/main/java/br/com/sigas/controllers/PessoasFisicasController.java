package br.com.sigas.controllers;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import br.com.sigas.entities.PessoasFisicas;
import br.com.sigas.services.PessoasFisicasService;
import jakarta.persistence.EntityExistsException;
import jakarta.persistence.EntityNotFoundException;

@RestController
@RequestMapping("/pessoaFisica")
public class PessoasFisicasController {

    @Autowired
    private PessoasFisicasService pessoasFisicasService;

    @PostMapping
    public ResponseEntity<?> criarPessoaFisica(@RequestBody PessoasFisicas pessoaFisica) {
        try {
            PessoasFisicas novaPessoaFisica = pessoasFisicasService.criarPessoaFisica(pessoaFisica);
            return ResponseEntity.status(HttpStatus.CREATED).body(novaPessoaFisica);
        } catch (EntityExistsException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Erro ao criar pessoa física: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao criar pessoa física: " + e.getMessage());
        }
    }

    @GetMapping("/id/{id}")
    public ResponseEntity<?> buscarPessoaFisicaPorId(@PathVariable Long id) {
        try {
            PessoasFisicas pessoaFisica = pessoasFisicasService.buscarPessoaFisicaPorId(id);
            return ResponseEntity.ok(pessoaFisica);
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Pessoa não encontrada.");
        }
    }

    @GetMapping("/cpf/{cpf}")
    public ResponseEntity<?> buscarPessoaFisicaPorCpf(@PathVariable String cpf) {
        try {
            PessoasFisicas pessoaFisica = pessoasFisicasService.buscarPessoaFisicaPorCpf(cpf);
            return ResponseEntity.ok(pessoaFisica);
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Pessoa não encontrada.");
        }
    }

    @GetMapping("/nome/{nome}")
    public ResponseEntity<?> buscarPessoaFisicaPorNome(@PathVariable("nome") String nome) {
        try {
            List<PessoasFisicas> pessoasFisicas = pessoasFisicasService.buscarPessoaFisicaPorNome(nome);
            if (pessoasFisicas.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Pessoas não encontradas.");
            }
            return ResponseEntity.ok(pessoasFisicas);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro interno do servidor: " + e.getMessage());
        }
    }

    @GetMapping("/email/{email}")
    public ResponseEntity<?> buscarPessoaFisicaPorEmail(@PathVariable("email") String email) {
        try {
            List<PessoasFisicas> pessoasFisicas = pessoasFisicasService.buscarPessoaFisicaPorEmail(email);
            if (pessoasFisicas.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Pessoa não encontradas.");
            }
            return ResponseEntity.ok(pessoasFisicas);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro interno do servidor: " + e.getMessage());
        }
    }

    @PutMapping("/update/{idPessoa}")
    public ResponseEntity<?> atualizarPessoaFisica(
            @PathVariable Long idPessoa,
            @RequestBody Map<String, String> dados) {
        try {
            // Extrair dados do JSON
            String cpf = dados.get("cpf");
            String nome = dados.get("nome");
            String email = dados.get("email");
            String endereco = dados.get("endereco");
            String tel1 = dados.get("tel1");
            String tel2 = dados.get("tel2");
    
            // Validações básicas
            if (nome == null || nome.isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("O Nome é obrigatório.");
            }
    
            if (cpf == null || cpf.isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("O CPF é obrigatório.");
            }
    
            // Chamar o serviço para executar a procedure
            pessoasFisicasService.atualizarPessoaFisica(idPessoa, cpf, nome, email, endereco, tel1, tel2);
    
            return ResponseEntity.ok("Pessoa física atualizada com sucesso!");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao atualizar pessoa física: " + e.getMessage());
        }
    }
    

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deletarPessoaFisica(@PathVariable Long id) {
        try {
            pessoasFisicasService.deletarPessoaFisicaProcedure(id);
            return ResponseEntity.ok("Pessoa física desativada com sucesso.");
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Pessoa física não encontrada.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao desativar pessoa física: " + e.getMessage());
        }
    }

}
