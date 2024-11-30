package br.com.sigas.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import br.com.sigas.entities.PessoasJuridicas;
import br.com.sigas.services.PessoasJuridicasService;
import jakarta.persistence.EntityExistsException;
import jakarta.persistence.EntityNotFoundException;

@RestController
@RequestMapping("/pessoaJuridica")
public class PessoasJuridicasController {

    @Autowired
    private PessoasJuridicasService pessoasJuridicasService;

    @PostMapping
    public ResponseEntity<?> criarPessoaJuridica(@RequestBody PessoasJuridicas pessoaJuridica) {
        try {
            PessoasJuridicas novaPessoaJuridica = pessoasJuridicasService.criarPessoaJuridica(pessoaJuridica);
            return ResponseEntity.status(HttpStatus.CREATED).body(novaPessoaJuridica);
        } catch (EntityExistsException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Erro ao criar pessoa jurídica: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao criar pessoa jurídica: " + e.getMessage());
        }
    }

    @GetMapping("/id/{id}")
    public ResponseEntity<?> buscaPessoaJuridicaPorId(@PathVariable long id) {
        try {
            PessoasJuridicas pessoaJuridica = pessoasJuridicasService.buscaPessoaJuridicaPorId(id);
            return ResponseEntity.ok(pessoaJuridica);
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Pessoa não encontrada.");
        }
    }

    @GetMapping("/cnpj/{cnpj}")
    public ResponseEntity<?> buscarPorTrechoCnpj(@PathVariable String cnpj) {
        try {
            List<PessoasJuridicas> pessoasJuridicas = pessoasJuridicasService.buscarPorTrechoCnpj(cnpj);
            if (pessoasJuridicas.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Nenhuma pessoa jurídica encontrada.");
            }
            return ResponseEntity.ok(pessoasJuridicas);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar por CNPJ: " + e.getMessage());
        }
    }

    @GetMapping("/nome/{nome}")

    public ResponseEntity<?> buscarPessoaJuridicaPorNome(@PathVariable("nome") String nome) {
        try {
            List<PessoasJuridicas> pessoasJuridicas = pessoasJuridicasService
                    .buscarPessoaJuridicaPorNome(nome);
            if (pessoasJuridicas.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Pessoas não encontradas.");
            }
            return ResponseEntity.ok(pessoasJuridicas);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar pessoas jurídicas: " + e.getMessage());
        }
    }

    @GetMapping("/razao-social/{razao_social}")
    public ResponseEntity<?> buscarPorRazaoSocial(
            @PathVariable("razao_social") String razao_social) {
        try {
            List<PessoasJuridicas> pessoasJuridicas = pessoasJuridicasService
                    .buscarPorRazaoSocial(razao_social);
            if (pessoasJuridicas.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Pessoas não encontradas.");
            }
            return ResponseEntity.ok(pessoasJuridicas);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar pessoas jurídicas: " + e.getMessage());
        }
    }

    @GetMapping("/email/{email}")
    public ResponseEntity<?> buscarPessoaJuridicaPorEmail(@PathVariable("email") String email) {
        try {
            List<PessoasJuridicas> pessoasJuridicas = pessoasJuridicasService
                    .buscarPessoaJuridicaPorEmail(email);
            if (pessoasJuridicas.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Pessoa não encontradas.");
            }
            return ResponseEntity.ok(pessoasJuridicas);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao buscar pessoas jurídicas: " + e.getMessage());
        }
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<?> atualizarPessoaJuridica(@PathVariable Long id,
            @RequestBody PessoasJuridicas pessoaJuridicaAtualizada) {
        try {
            pessoasJuridicasService.atualizarPessoaJuridica(id, pessoaJuridicaAtualizada);
            return ResponseEntity.ok("Pessoa jurídica atualizada com sucesso!");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao atualizar pessoa jurídica: " + e.getMessage());
        }
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deletarPessoaJuridica(@PathVariable Long id) {
        try {
            pessoasJuridicasService.deletarPessoaJuridicaProcedure(id);
            return ResponseEntity.ok("Pessoa jurídica desativada com sucesso.");
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Pessoa jurídica não encontrada.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Erro ao desativar pessoa jurídica: " + e.getMessage());
        }
    }

}